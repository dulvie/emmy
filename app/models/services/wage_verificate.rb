module Services
  class WageVerificate
    attr_reader :errors

    def initialize(wage_period, post_date)
      @errors = []
      @wage_period = wage_period
      @organization = @wage_period.organization
      @accounting_period = @organization.accounting_periods
                               .where('accounting_from <= ? AND accounting_to >= ?',
                                      post_date, post_date)
                               .first
      if @accounting_period.nil?
        @errors << "Unable to find accounting period"
        Rails.logger.info "-->>WageVerificate error accounting period missing"
        return
      end
      @accounting_plan = @accounting_period.accounting_plan
      @verificate_creator = Services::VerificateCreator.new(@accounting_period, @wage_period)
    end

    def valid?
      errors.empty?
    end

    def wage
      # wage per result_unit + payment to bankaccount + add result_unit to ver_item
      Verificate.transaction do

        # create verificate
        @verificate_creator.save_verificate(@wage_period.payment_date, 'Salery payout', '', '', nil, 'wage')

        # create total salery
        tax_code = tax_code(50)
        account = account_from_tax_code(tax_code)
        amount = @wage_period.total_salary
        @verificate_creator.save_verificate_item(account, amount, 0)

        # create wage tax
        tax_code = tax_code(82)
        account = account_from_tax_code(tax_code)
        amount = @wage_period.total_tax
        @verificate_creator.save_verificate_item(account, 0, amount)

        # create payroll debet
        tax_code = tax_code(100)
        account = account_from_tax_code(tax_code)
        amount = @wage_period.total_payroll_tax
        @verificate_creator.save_verificate_item(account, amount, 0)

        # create payroll credit
        tax_code = tax_code(78)
        account = account_from_tax_code(tax_code)
        amount = @wage_period.total_payroll_tax
        @verificate_creator.save_verificate_item(account, 0, amount)

        # create payment
        default_code = default_code(01)
        account = account_from_default_code(default_code)
        amount = @wage_period.total_amount
        @verificate_creator.save_verificate_item(account, 0, amount)
      end
    end


    def tax
      Verificate.transaction do
        # create verificate
        @verificate_creator.save_verificate(@wage_period.deadline, 'Skatteredovisning','','', nil, 'tax')

        # create create payroll
        tax_code = tax_code(78)
        account = account_from_tax_code(tax_code)
        amount = wage_amount(tax_code)
        @verificate_creator.save_verificate_item(account, amount, 0)

        # create wage tax
        tax_code = tax_code(82)
        account = account_from_tax_code(tax_code)
        amount = wage_amount(tax_code)
        @verificate_creator.save_verificate_item(account, amount, 0)

        # create payment
        tax_code = tax_code(99)
        default_code = default_code(01)
        account = account_from_default_code(default_code)
        amount = wage_amount(tax_code)
        @verificate_creator.save_verificate_item(account, 0, amount)
      end
    end

    def wage_amount(tax_code)
      wage_report = @wage_period.wage_reports.where('tax_code_id = ?', tax_code.id).first
      return wage_report.amount
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
