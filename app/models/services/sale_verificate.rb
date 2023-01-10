module Services
  class SaleVerificate
    attr_reader :errors

    def initialize(sale, post_date)
      @errors = []
      @sale = sale
      @organization = @sale.organization
      @accounting_period = @organization.accounting_periods
                               .where('accounting_from <= ? AND accounting_to >= ?',
                                      post_date, post_date)
                               .first
      if @accounting_period.nil?
        @errors << "Unable to find accounting period"
        Rails.logger.info "-->>SaleVerificate error accounting period missing"
        return
      end
      @accounting_plan = @accounting_period.accounting_plan
      @verificate_creator = Services::VerificateCreator.new(@accounting_period, @sale)
    end

    def valid?
      errors.empty?
    end

    def verificate_id
      @verificate_creator.verificate_id
    end

    def accounts_receivable
      Verificate.transaction do

        # create verificate
        ver_dsc = I18n.t(:customer) + ' ' + I18n.t(:invoice) + ' ' + @sale.invoice_number.to_s
        @verificate_creator.save_verificate(@sale.approved_at, ver_dsc, '', '', nil, nil)

        # create sale
        some_code = default_code(05)
        account = account_from_default_code(some_code)
        @verificate_creator.save_verificate_item(account, 0, @sale.total_price/100)

        # create vat 25
        tx_code = tax_code(10)
        account = account_from_tax_code(tx_code)
        @verificate_creator.save_verificate_item(account, 0, @sale.total_vat_25/100)

        # create vat 12
        tx_code = tax_code(11)
        account = account_from_tax_code(tx_code)
        @verificate_creator.save_verificate_item(account, 0, @sale.total_vat_12/100)

        # create vat 06
        tx_code = tax_code(12)
        account = account_from_tax_code(tx_code)
        @verificate_creator.save_verificate_item(account, 0, @sale.total_vat_06/100)

        # create rounding
        some_code = default_code(02)
        account = account_from_default_code(some_code)
        if @sale.total_rounding > 0
          @verificate_creator.save_verificate_item(account, 0, @sale.total_rounding/100)
        else
          @verificate_creator.save_verificate_item(account, -@sale.total_rounding/100, 0)
        end

        # create account receivable
        some_code = default_code(03)
        account = account_from_default_code(some_code)
        @verificate_creator.save_verificate_item(account, @sale.total_after_rounding/100, 0)
      end
    end

    def accounts_receivable_reverse
      Verificate.transaction do

        # create verificate
        ver_dsc = I18n.t(:reverse) + ' ' + I18n.t(:customer) + ' ' + I18n.t(:invoice) + ' ' + @sale.invoice_number.to_s
        @verificate_creator.save_verificate(@sale.canceled_at, ver_dsc, '', '', nil, nil)

        # create sale
        some_code = default_code(05)
        account = account_from_default_code(some_code)
        @verificate_creator.save_verificate_item(account, @sale.total_price/100, 0)

        # create vat 25
        tx_code = tax_code(10)
        account = account_from_tax_code(tx_code)
        @verificate_creator.save_verificate_item(account, @sale.total_vat_25/100, 0)

        # create vat 12
        tx_code = tax_code(11)
        account = account_from_tax_code(tx_code)
        @verificate_creator.save_verificate_item(account, @sale.total_vat_12/100, 0)

        # create vat 06
        tx_code = tax_code(12)
        account = account_from_tax_code(tx_code)
        @verificate_creator.save_verificate_item(account, @sale.total_vat_06/100, 0)

        # create rounding
        some_code = default_code(02)
        account = account_from_default_code(some_code)
        if @sale.total_rounding > 0
          @verificate_creator.save_verificate_item(account, @sale.total_rounding/100, 0)
        else
          @verificate_creator.save_verificate_item(account, 0, -@sale.total_rounding/100)
        end

        # create account receivable
        some_code = default_code(03)
        account = account_from_default_code(some_code)
        @verificate_creator.save_verificate_item(account, 0, @sale.total_after_rounding/100)
      end
    end

    def customer_payments
      Verificate.transaction do

        # create verificate
        ver_dsc = I18n.t(:customer) + ' ' + I18n.t(:payment)
        @verificate_creator.save_verificate(@sale.paid_at, ver_dsc, '', '', nil, nil)

        # create account receivable
        some_code = default_code(03)
        account = account_from_default_code(some_code)
        @verificate_creator.save_verificate_item(account, 0, @sale.total_after_rounding/100)

        # create customer payments
        some_code = default_code(01)
        account = account_from_default_code(some_code)
        @verificate_creator.save_verificate_item(account, @sale.total_after_rounding/100, 0)
      end
    end

    def reverse_charge(vat_number, result_unit)
      Verificate.transaction do
        # create verificate
        ver_dsc = I18n.t(:payment) + ' ' + I18n.t(:reversed_vat)
        @verificate_creator.save_verificate(@sale.paid_at, ver_dsc, '', '', nil, vat_number)

        # create income
        tx_code = tax_code(39)
        account = account_from_tax_code(tx_code)
        @verificate_creator.save_verificate_item(account, 0, BigDecimal(@sale.total_price)/100, result_unit)

        # create customer payments
        some_code = default_code(01)
        account = account_from_default_code(some_code)
        @verificate_creator.save_verificate_item(account, BigDecimal(@sale.total_price)/100, 0)
      end
    end

    def tax_code(code)
      @organization.tax_codes.find_by_code(code)
    end

    def account_from_tax_code(tax_code)
      @accounting_plan.accounts.find_by_tax_code_id(tax_code.id)
    end

    def default_code(code)
      @organization.default_codes.find_by_code(code)
    end

    def account_from_default_code(default_code)
      @accounting_plan.accounts.find_by_default_code_id(default_code.id)
    end
  end
end
