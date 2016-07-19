module Services
  class VatVerificate
    attr_reader :errors

    def initialize(vat_period, post_date)
      @errors = []
      @vat_period = vat_period
      @organization = @vat_period.organization
      @accounting_period = @organization.accounting_periods
                               .where('accounting_from <= ? AND accounting_to >= ?',
                                      post_date, post_date)
                               .first
      if @accounting_period.nil?
        @errors << "Unable to find accounting period"
        Rails.logger.info "-->>VatVerificate error accounting period missing"
        return
      end
      @accounting_plan = @accounting_period.accounting_plan
      @verificate_creator = Services::VerificateCreator.new(@accounting_period, @vat_period)
    end

    def valid?
      errors.empty?
    end

    def verificate_id
      @verificate.id
    end

    def create
      Verificate.transaction do

        # create verificate
        @verificate_creator.save_verificate(@vat_period.deadline, 'Momsredovisning','','', nil, nil)

        # create vat 25
        tax_code = tax_code(10)
        account = account_from_tax_code(tax_code)
        amount = vat_amount(tax_code)
        @verificate_creator.save_verificate_item(account, amount, 0)

        # create vat 12
        tax_code = tax_code(11)
        account = account_from_tax_code(tax_code)
        amount = vat_amount(tax_code)
        @verificate_creator.save_verificate_item(account, amount, 0)

        # create vat 06
        tax_code = tax_code(12)
        account = account_from_tax_code(tax_code)
        amount = vat_amount(tax_code)
        @verificate_creator.save_verificate_item(account, amount, 0)

        # create vat incoming
        tax_code = tax_code(48)
        account = account_from_tax_code(tax_code)
        amount = vat_amount(tax_code)
        @verificate_creator.save_verificate_item(account, 0, -amount)

        # create vat payments
        tax_code = tax_code(49)
        default_code = default_code(01)
        account = account_from_default_code(default_code)
        amount = vat_amount(tax_code)
        @verificate_creator.save_verificate_item(account, 0, amount)
      end
    end

    def vat_amount(tax_code)
      vat_report = @vat_period.vat_reports.where('tax_code_id = ?', tax_code.id).first
      return vat_report.amount
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
