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

    def initializeOld(organization, user, object)
      @user = user
      @organization = organization
      @object = object
      @verificate
    end

    def verificate_id
      @verificate.id
    end

    def save_vat_report
      vat_period = @object
      accounting_period = @organization.accounting_periods.find(vat_period.accounting_period_id)
      if vat_period.deadline > accounting_period.accounting_to
        accounting_period = accounting_period.next_accounting_period
      end
      accounting_plan = accounting_period.accounting_plan

      save_verificate(vat_period.deadline, 'Momsredovisning','','',accounting_period, nil)

      vat_period.vat_reports.each do |report|
        account = accounting_plan.accounts.find_by_tax_code_id(report.tax_code.id)

        if report.amount != 0 && (report.tax_code.code == 10 || report.tax_code.code == 11 || report.tax_code.code == 12)
          save_verificate_item(@verificate, account, report.amount, 0, accounting_period)
        elsif report.amount != 0 && report.tax_code.code == 48
          save_verificate_item(@verificate, account, 0, -report.amount, accounting_period)
        elsif report.tax_code.code == 49
          account_pay = account_from_default_code(accounting_plan, 01)
          save_verificate_item(@verificate, account_pay, 0, report.amount, accounting_period)
        else
        end
      end
      if vat_period.calculated?
        vat_period.state_change('mark_reported', DateTime.now)
      end
    end

    def save_wage
      wage_period = @object
      accounting_period = @organization.accounting_periods.find(wage_period.accounting_period_id)
      accounting_plan = accounting_period.accounting_plan

      save_verificate(wage_period.payment_date, 'Salery payout', '', '', accounting_period, nil)
      # @NOTE payout seperate for every employee to account??
      sum_salary = 0
      sum_tax = 0
      sum_payroll_tax = 0
      sum_amount = 0
      wage_period.wages.each do |report|
        sum_salary += report.salary
        sum_tax += report.tax
        sum_payroll_tax += report.payroll_tax
        sum_amount += report.amount
      end

      account_wage_sum = account_from_tax_code(accounting_plan, 50)
      save_verificate_item(@verificate, account_wage_sum, sum_salary, 0, accounting_period)
      @verificate.parent_extend = 'wage'
      @verificate.save

      account_wage_tax = account_from_tax_code(accounting_plan, 82)
      save_verificate_item(@verificate, account_wage_tax, 0, sum_tax, accounting_period)

      account_payroll_deb = account_from_tax_code(accounting_plan, 100)
      save_verificate_item(@verificate, account_payroll_deb, sum_payroll_tax, 0, accounting_period)

      account_payroll_cre = account_from_tax_code(accounting_plan, 78)
      save_verificate_item(@verificate, account_payroll_cre, 0, sum_payroll_tax, accounting_period)

      account_pay = account_from_default_code(accounting_plan, 01)
      save_verificate_item(@verificate, account_pay, 0, sum_amount, accounting_period)
      
      wage_period.state_change('mark_wage_reported', DateTime.now)
    end

    def save_wage_report
      wage_period = @object
      accounting_period = AccountingPeriod.find(wage_period.accounting_period_id)
      accounting_plan = accounting_period.accounting_plan

      save_verificate(wage_period.deadline, 'Skatteredovisning','','', accounting_period, nil)
      @verificate.parent_extend = 'tax'
      @verificate.save

      wage_period.wage_reports.each do |report|
        account = accounting_plan.accounts.find_by_tax_code_id(report.tax_code.id)
        if report.amount != 0 && (report.tax_code.code == 78 || report.tax_code.code == 82)
          save_verificate_item(@verificate, account, report.amount, 0, accounting_period)
        elsif report.tax_code.code == 99
          account_pay = account_from_default_code(accounting_plan, 01)
          save_verificate_item(@verificate, account_pay, 0, report.amount, @accounting_period)
        else
        end
      end

      wage_period.state_change('mark_tax_reported', DateTime.now)
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
      save_verificate(sale.approved_at, ver_dsc, '', '', @accounting_period, nil)

       # create sale
      account_sale = account_from_default_code(@accounting_plan, 05)
      save_verificate_item(@verificate, account_sale, 0, sale.total_price/100, @accounting_period)

      # create vat 25
      account_vat25 = account_from_tax_code(@accounting_plan, 10)
      save_verificate_item(@verificate, account_vat25, 0, sale.total_vat_25/100, @accounting_period)

      # create vat 12
      account_vat12 = account_from_tax_code(@accounting_plan, 11)
      save_verificate_item(@verificate, account_vat12, 0, sale.total_vat_1/100, @accounting_period)

      # create vat 06
      account_vat06 = account_from_tax_code(@accounting_plan, 12)
      save_verificate_item(@verificate, account_vat06, 0, sale.total_vat_06/100, @accounting_period)

      # create rounding
      account_rounding = account_from_default_code(@accounting_plan, 02)
      if sale.total_rounding > 0
        save_verificate_item(@verificate, account_rounding, 0, sale.total_rounding/100, @accounting_period)
      else
        save_verificate_item(@verificate, account_rounding, -sale.total_rounding/100, 0, @accounting_period)
      end

      # create account receivable
      account_receivable = account_from_default_code(@accounting_plan, 03)
      save_verificate_item(@verificate, account_receivable, sale.total_after_rounding/100, 0, @accounting_period)
      end
    end


    def accounts_receivable_reverse
      sale = @object

      Verificate.transaction do

      # create verificate
      ver_dsc = I18n.t(:reverse) + ' ' + I18n.t(:customer) + ' ' + I18n.t(:invoice) + ' ' + sale.invoice_number.to_s
      save_verificate(sale.canceled_at, ver_dsc, '', '', @accounting_period, nil)

      # create sale
      account_sale = account_from_default_code(@accounting_plan, 05)
      save_verificate_item(@verificate, account_sale, sale.total_price/100, 0, @accounting_period)

      # create vat 25
      account_vat25 = account_from_tax_code(@accounting_plan, 10)
      save_verificate_item(@verificate, account_vat25, sale.total_vat_25/100, 0, @accounting_period)

      # create vat 12
      account_vat12 = account_from_tax_code(@accounting_plan, 11)
      save_verificate_item(@verificate, account_vat12, sale.total_vat_12/100, 0, @accounting_period)

      # create vat 06
      account_vat06 = account_from_tax_code(@accounting_plan, 12)
      save_verificate_item(@verificate, account_vat06, sale.total_vat_06/100, 0, @accounting_period)

      # create rounding
      account_rounding = account_from_default_code(@accounting_plan, 02)
      if sale.total_rounding > 0
        save_verificate_item(@verificate, account_rounding, sale.total_rounding/100, 0, @accounting_period)
      else
        save_verificate_item(@verificate, account_rounding, 0, -sale.total_rounding/100, @accounting_period)
      end

      # create account receivable
      account_receivable = account_from_default_code(@accounting_plan, 03)
      save_verificate_item(@verificate, account_receivable, 0, sale.total_after_rounding/100, @accounting_period)
      end
    end

    def customer_payments
      sale = @object

      Verificate.transaction do

      # create verificate
      ver_dsc = I18n.t(:customer) + ' ' + I18n.t(:payment)
      save_verificate(sale.paid_at, ver_dsc, '', '', @accounting_period, nil)

      # create account receivable
      account_receivable = account_from_default_code(@accounting_plan, 03)
      save_verificate_item(@verificate, account_receivable, 0, sale.total_after_rounding/100, @accounting_period)

      # create customer payments
      customer_payment = account_from_default_code(@accounting_plan, 01)
      save_verificate_item(@verificate, customer_payment, sale.total_after_rounding/100, 0, @accounting_period)
      end
    end

    def accounts_payable
      purchase = @object
      accounting_period = @organization.accounting_periods.where('accounting_from <= ? AND accounting_to >= ?', purchase.ordered_at, purchase.ordered_at).first
      accounting_plan = @organization.accounting_plans.find(accounting_period.accounting_plan_id)

      ver_dsc = purchase.description
      save_verificate(purchase.ordered_at, ver_dsc, '', '', accounting_period, nil)

      # Kostnadsförs manuellt på rätt kostnadskonto

      account_vat = account_from_tax_code(accounting_plan, 48)
      save_verificate_item(@verificate, account_vat, BigDecimal.new(purchase.total_vat)/100, 0, accounting_period)

      account_payable = account_from_default_code(accounting_plan, 04)
      save_verificate_item(@verificate, account_payable, 0, BigDecimal.new(purchase.total_amount)/100, accounting_period)
    end

    def supplier_payments
      purchase = @object
      accounting_period = @organization.accounting_periods.where('accounting_from <= ? AND accounting_to >= ?', purchase.paid_at, purchase.paid_at).first
      accounting_plan = @organization.accounting_plans.find(accounting_period.accounting_plan_id)

      ver_dsc = I18n.t(:supplier) + ' ' + I18n.t(:payment)
      save_verificate(purchase.paid_at, ver_dsc, '', '', accounting_period, nil)

      account_payable = account_from_default_code(accounting_plan, 04)
      save_verificate_item(@verificate, account_payable, BigDecimal.new(purchase.total_amount)/100, 0, accounting_period)

      supplier_payment = account_from_default_code(accounting_plan, 01)
      save_verificate_item(@verificate, supplier_payment, 0, BigDecimal.new(purchase.total_amount)/100, accounting_period)
    end

    def account_from_tax_code(accounting_plan, tax_code)
      code = @organization.tax_codes.find_by_code(tax_code)
      @account = accounting_plan.accounts.find_by_tax_code_id(code.id)
      return @account
    end

    def account_from_default_code(accounting_plan, default_code)
      code = @organization.default_codes.find_by_code(default_code)
      @account = accounting_plan.accounts.find_by_default_code_id(code.id)
      return @account
    end

    def save_in_template(template_id)
      # Förutsätter att det är en bankfilrow
      import_bank_file_row = @object
      template = @organization.templates.find(template_id)
      accounting_period = @organization.accounting_periods.where('accounting_from <= ? AND accounting_to >= ?', import_bank_file_row.posting_date, import_bank_file_row.posting_date).first

      save_verificate( import_bank_file_row.posting_date, template.description, import_bank_file_row.reference, import_bank_file_row.note, accounting_period, template)
      return @verificate.id
    end

    def reversal
      verificate = @object
      accounting_period = verificate.accounting_period

      ver_dsc = I18n.t(:reversal) + ' ' + I18n.t(:verificate) + ' ' + verificate.number.to_s
      save_verificate(DateTime.now, ver_dsc, '', '', accounting_period, nil)

      verificate.verificate_items.each do |verificate_item|
        save_verificate_item(@verificate, verificate_item.account, verificate_item.credit, verificate_item.debit, accounting_period)
      end
    end

    def save_verificate(posting_date, description, reference, note, accounting_period, template)
      @verificate = Verificate.new
      @verificate.posting_date = posting_date
      @verificate.description = description
      @verificate.reference = reference
      @verificate.note = note
      @verificate.organization = @organization
      @verificate.accounting_period = accounting_period
      @verificate.template = template if template
      @verificate.parent_type = @object.class.name
      @verificate.parent_id = @object.id
      @verificate.save
      return @verificate
    end

    def save_verificate_item(verificate, account, debit, credit, accounting_period)
      return if debit == 0 && credit == 0
      verificate_item = verificate.verificate_items.build
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
      verificate_item.accounting_period = accounting_period
      verificate_item.save
    end
  end
end
