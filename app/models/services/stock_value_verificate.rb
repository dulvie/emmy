module Services
  class StockValueVerificate
    attr_reader :errors

    def initialize(stock_value, post_date)
      @errors = []
      @stock_value = stock_value
      @organization = @stock_value.organization
      @accounting_period = @organization.accounting_periods
                               .where('accounting_from <= ? AND accounting_to >= ?',
                                      post_date, post_date)
                               .first
      if @accounting_period.nil?
        @errors << "Unable to find accounting period"
        Rails.logger.info "-->>StockValueVerificate error accounting period missing"
        return
      end
      @accounting_plan = @accounting_period.accounting_plan
      @verificate_creator = Services::VerificateCreator.new(@accounting_period, @stock_value)
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
        ver_dsc = @stock_value.name
        @verificate_creator.save_verificate(@stock_value.reported_at, ver_dsc, '', '', nil)

        # beräkna förändringen i lagervärde
        default_code = default_code(06)
        account = account_from_default_code(default_code)
        ledger_account = @accounting_period.ledger.ledger_accounts.where('account_id = ?', account.id).first
        account_sum = 0
        if !ledger_account.blank?
          account_sum = ledger_account.sum
        end
        diff = @stock_value.value - account_sum

        # create lagervärde handelsvaror
        @verificate_creator.save_verificate_item(account, diff, 0)

        # create lagervärde förändring
        default_code = default_code(07)
        account = account_from_default_code(default_code)
        @verificate_creator.save_verificate_item(account, 0, diff)
      end
    end

    def default_code(code)
      @organization.default_codes.find_by_code(code)
    end

    def account_from_default_code(default_code)
      @accounting_plan.accounts.find_by_default_code_id(default_code.id)
    end
  end
end
