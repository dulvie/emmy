module Services
  class PurchaseVerificate
    attr_reader :errors

    def initialize(purchase, post_date)
      @errors = []
      @purchase = purchase
      @organization = @purchase.organization
      @accounting_period = @organization.accounting_periods
                               .where('accounting_from <= ? AND accounting_to >= ?',
                                      post_date, post_date)
                               .first
      if @accounting_period.nil?
        @errors << "Unable to find accounting period"
        Rails.logger.info "-->>PurchaseVerificate error accounting period missing"
        return
      end
      @accounting_plan = @accounting_period.accounting_plan
      @verificate_creator = Services::VerificateCreator.new(@accounting_period, @purchase)
    end

    def valid?
      errors.empty?
    end

    def verificate_id
      @verificate.id
    end

    def accounts_payable
      Verificate.transaction do
        # create verificate
        ver_dsc = @purchase.description
        @verificate_creator.save_verificate(@purchase.ordered_at, ver_dsc, '', '', nil, nil)

        # Kostnadsförs manuellt på rätt kostnadskonto

        # create vat
        tax_code = tax_code(48)
        account = account_from_tax_code(tax_code)
        @verificate_creator.save_verificate_item(account, BigDecimal(@purchase.total_vat)/100, 0)

        # create accounts payable
        default_code = default_code(04)
        account = account_from_default_code(default_code)
        @verificate_creator.save_verificate_item(account, 0, BigDecimal(@purchase.total_amount)/100)
      end
    end

    def supplier_payments
      Verificate.transaction do

        # create verificate
        ver_dsc = I18n.t(:supplier) + ' ' + I18n.t(:payment)
        @verificate_creator.save_verificate(@purchase.paid_at, ver_dsc,'','', nil, nil)

        # create accounts payable
        default_code = default_code(04)
        account = account_from_default_code(default_code)
        @verificate_creator.save_verificate_item(account, BigDecimal(@purchase.total_amount)/100, 0)

        # create supplier payments
        default_code = default_code(01)
        account = account_from_default_code(default_code)
        @verificate_creator.save_verificate_item(account, 0, BigDecimal(@purchase.total_amount)/100)
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
