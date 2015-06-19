module Services
  class VerificateCreator

    def initialize(organization, user, object, post_date)
      @user = user
      @organization = organization
      @object = object
      @verificate
      @accounting_period = @organization.accounting_periods.where('accounting_from <= ? AND accounting_to >= ?', post_date, post_date).first
      if @accounting_period.nil?
        Rails.logger.info "-->>VerificateCreator error accounting period missing"
      end
      @accounting_plan = @organization.accounting_plans.find(@accounting_period.accounting_plan_id)
    end

    def verificate_id
      @verificate.id
    end

    def vat_report
      vat_period = @object

      Verificate.transaction do

      # create verificate
      save_verificate(vat_period.deadline, 'Momsredovisning','','', nil)

      # create vat 25
      tax_code = tax_code(10)
      account = account_from_tax_code(tax_code)
      amount = vat_amount(vat_period, tax_code)
      save_verificate_item(account, amount, 0)

      # create vat 12
      tax_code = tax_code(11)
      account = account_from_tax_code(tax_code)
      amount = vat_amount(vat_period, tax_code)
      save_verificate_item(account, amount, 0)

      # create vat 06
      tax_code = tax_code(12)
      account = account_from_tax_code(tax_code)
      amount = vat_amount(vat_period, tax_code)
      save_verificate_item(account, amount, 0)

      # create vat incoming
      tax_code = tax_code(48)
      account = account_from_tax_code(tax_code)
      amount = vat_amount(vat_period, tax_code)
      save_verificate_item(account, 0, -amount)

      # create vat payments
      tax_code = tax_code(49)
      default_code = default_code(01)
      account = account_from_default_code(default_code)
      amount = vat_amount(vat_period, tax_code)
      save_verificate_item(account, 0, amount)
      end
    end

    def wage
      wage_period = @object

      Verificate.transaction do

      # create verificate
      save_verificate(wage_period.payment_date, 'Salery payout', '', '', nil)
      @verificate.parent_extend = 'wage'
      @verificate.save

      # create total salery
      tax_code = tax_code(50)
      account = account_from_tax_code(tax_code)
      amount = wage_period.total_salary
      save_verificate_item(account, amount, 0)

      # create wage tax
      tax_code = tax_code(82)
      account = account_from_tax_code(tax_code)
      amount = wage_period.total_tax
      save_verificate_item(account, 0, amount)

      # create payroll debet
      tax_code = tax_code(100)
      account = account_from_tax_code(tax_code)
      amount = wage_period.total_payroll_tax
      save_verificate_item(account, amount, 0)

      # create payroll credit
      tax_code = tax_code(78)
      account = account_from_tax_code(tax_code)
      amount = wage_period.total_payroll_tax
      save_verificate_item(account, 0, amount)

      # create payment
      default_code = default_code(01)
      account = account_from_default_code(default_code)
      amount = wage_period.total_amount
      save_verificate_item(account, 0, amount)
      end
    end

    def wage_tax
    wage_period = @object

      Verificate.transaction do

      # create verificate
      save_verificate(wage_period.deadline, 'Skatteredovisning','','', nil)
      @verificate.parent_extend = 'tax'
      @verificate.save

      # create create payroll
      tax_code = tax_code(78)
      account = account_from_tax_code(tax_code)
      amount = wage_period.total_payroll_tax
      save_verificate_item(account, amount, 0)

      # create wage tax
      tax_code = tax_code(82)
      account = account_from_tax_code(tax_code)
      amount = wage_period.total_tax
      save_verificate_item(account, amount, 0)

      # create payment
      default_code = default_code(01)
      account = account_from_default_code(default_code)
      amount = wage_period.sum_tax
      save_verificate_item(account, 0, amount)
      end
    end

    def bank_file_row
      import_bank_file_row = @object

      Verificate.transaction do

      save_verificate( import_bank_file_row.posting_date, import_bank_file_row.name, import_bank_file_row.reference, import_bank_file_row.note, nil)

      # create payment
      if import_bank_file_row.amount > 0
        debit = import_bank_file_row.amount
        credit = 0
      else
        debit = 0
        credit = -import_bank_file_row.amount
      end
      default_code = default_code(01)
      account = account_from_default_code(default_code)
      save_verificate_item(account, debit, credit)
      end
    end

    def save_bank_file_row
      import_bank_file_row = @object
      accounting_period = @organization.accounting_periods.where('accounting_from <= ? AND accounting_to >= ?', import_bank_file_row.posting_date, import_bank_file_row.posting_date).first
      accounting_plan = accounting_period.accounting_plan

      save_verificate( import_bank_file_row.posting_date, import_bank_file_row.name, import_bank_file_row.reference, import_bank_file_row.note, accounting_period, nil)

      if import_bank_file_row.amount > 0
        debit = import_bank_file_row.amount
        credit = 0
      else
        debit = 0
        credit = -import_bank_file_row.amount
      end
      account = account_from_default_code(accounting_plan, 01)
      save_verificate_item(@verificate, account, debit, credit, accounting_period)
      return @verificate.id
    end

    def accounts_receivable
      sale = @object

      Verificate.transaction do

      # create verificate
      ver_dsc = I18n.t(:customer) + ' ' + I18n.t(:invoice) + ' ' + sale.invoice_number.to_s
      save_verificate(sale.approved_at, ver_dsc, '', '', nil)

      # create sale
      default_code = default_code(05)
      account = account_from_default_code(default_code)
      save_verificate_item(account, 0, sale.total_price/100)

      # create vat 25
      tax_code = tax_code(10)
      account = account_from_tax_code(tax_code)
      save_verificate_item(account, 0, sale.total_vat_25/100)

      # create vat 12
      tax_code = tax_code(11)
      account = account_from_tax_code(tax_code)
      save_verificate_item(account, 0, sale.total_vat_12/100)

      # create vat 06
      tax_code = tax_code(12)
      account = account_from_tax_code(tax_code)
      save_verificate_item(account, 0, sale.total_vat_06/100)

      # create rounding
      default_code = default_code(02)
      account = account_from_default_code(default_code)
      if sale.total_rounding > 0
        save_verificate_item(account, 0, sale.total_rounding/100)
      else
        save_verificate_item(account, -sale.total_rounding/100, 0)
      end

      # create account receivable
      default_code = default_code(03)
      account = account_from_default_code(default_code)
      save_verificate_item(account, sale.total_after_rounding/100, 0)
      end
    end


    def accounts_receivable_reverse
      sale = @object

      Verificate.transaction do

      # create verificate
      ver_dsc = I18n.t(:reverse) + ' ' + I18n.t(:customer) + ' ' + I18n.t(:invoice) + ' ' + sale.invoice_number.to_s
      save_verificate(sale.canceled_at, ver_dsc, '', '', nil)

      # create sale
      default_code = default_code(05)
      account = account_from_default_code(default_code)
      save_verificate_item(account, sale.total_price/100, 0)

      # create vat 25
      tax_code = tax_code(10)
      account = account_from_tax_code(tax_code)
      save_verificate_item(account, sale.total_vat_25/100, 0)

      # create vat 12
      tax_code = tax_code(11)
      account = account_from_tax_code(tax_code)
      save_verificate_item(account, sale.total_vat_12/100, 0)

      # create vat 06
      tax_code = tax_code(12)
      account = account_from_tax_code(tax_code)
      save_verificate_item(account, sale.total_vat_06/100, 0)

      # create rounding
      default_code = default_code(02)
      account = account_from_default_code(default_code)
      if sale.total_rounding > 0
        save_verificate_item(account, sale.total_rounding/100, 0)
      else
        save_verificate_item(account, 0, -sale.total_rounding/100)
      end

      # create account receivable
      default_code = default_code(03)
      account = account_from_default_code(default_code)
      save_verificate_item(account, 0, sale.total_after_rounding/100)
      end
    end

    def customer_payments
      sale = @object

      Verificate.transaction do

      # create verificate
      ver_dsc = I18n.t(:customer) + ' ' + I18n.t(:payment)
      save_verificate(sale.paid_at, ver_dsc, '', '', nil)

      # create account receivable
      default_code = default_code(03)
      account = account_from_default_code(default_code)
      save_verificate_item(account, 0, sale.total_after_rounding/100)

      # create customer payments
      default_code = default_code(01)
      account = account_from_default_code(default_code)
      save_verificate_item(customer_payment, sale.total_after_rounding/100, 0)
      end
    end

    def accounts_payable
      purchase = @object

      Verificate.transaction do

      # create verificate
      ver_dsc = purchase.description
      save_verificate(purchase.ordered_at, ver_dsc, '', '', nil)

      # Kostnadsförs manuellt på rätt kostnadskonto

      # create vat
      tax_code = tax_code(48)
      account = account_from_tax_code(tax_code)
      save_verificate_item(account, BigDecimal.new(purchase.total_vat)/100, 0)

      # create accounts payable
      default_code = default_code(04)
      account = account_from_default_code(default_code)
      save_verificate_item(account, 0, BigDecimal.new(purchase.total_amount)/100)
      end
    end

    def supplier_payments
      purchase = @object

      Verificate.transaction do

      # create verificate
      ver_dsc = I18n.t(:supplier) + ' ' + I18n.t(:payment)
      save_verificate(purchase.paid_at, ver_dsc, '', '', nil)

      # create accounts payable
      default_code = default_code(04)
      account = account_from_default_code(default_code)
      save_verificate_item(account, BigDecimal.new(purchase.total_amount)/100, 0)

      # create supplier payments
      default_code = default_code(01)
      account = account_from_default_code(default_code)
      save_verificate_item(supplier_payment, 0, BigDecimal.new(purchase.total_amount)/100)
      end
    end

    def tax_code(code)
      @organization.tax_codes.find_by_code(code)
    end

    def default_code(code)
      @organization.default_codes.find_by_code(code)
    end

    def account_from_tax_code(tax_code)
      @accounting_plan.accounts.find_by_tax_code_id(tax_code.id)
    end

    def account_from_default_code(default_code)
      @accounting_plan.accounts.find_by_default_code_id(default_code.id)
    end

    def vat_amount(vat_period, tax_code)
      vat_report = vat_period.vat_reports.where('tax_code_id = ?', tax_code.id).first
      return vat_report.amount
    end

    def template(template_id)
      import_bank_file_row = @object
      
      template = @organization.templates.find(template_id)
      save_verificate( import_bank_file_row.posting_date, template.description, import_bank_file_row.reference, import_bank_file_row.note, template)
    end

    def reversal
      verificate = @object

      # create verificate
      ver_dsc = I18n.t(:reversal) + ' ' + I18n.t(:verificate) + ' ' + verificate.number.to_s
      save_verificate(DateTime.now, ver_dsc, '', '', nil)

      # create reversal items
      verificate.verificate_items.each do |verificate_item|
        save_verificate_item(verificate_item.account, verificate_item.credit, verificate_item.debit)
      end
    end

    def save_verificate(posting_date, description, reference, note, template)
      @verificate = Verificate.new
      @verificate.posting_date = posting_date
      @verificate.description = description
      @verificate.reference = reference
      @verificate.note = note
      @verificate.organization = @organization
      @verificate.accounting_period = @accounting_period
      @verificate.template = template if template
      @verificate.parent_type = @object.class.name
      @verificate.parent_id = @object.id
      @verificate.save
    end

    def save_verificate_item(account, debit, credit)
      return if debit == 0 && credit == 0
      verificate_item = @verificate.verificate_items.build
      verificate_item.account_id = account.id
      verificate_item.description = account.description
      if debit < 0 || credit < 0
        verificate_item.debit = -credit
        verificate_item.credit = -debit
      else
        verificate_item.debit = debit
        verificate_item.credit = credit
      end
      verificate_item.organization = @organization
      verificate_item.accounting_period = @accounting_period
      verificate_item.save
    end
  end
end
