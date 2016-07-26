module Services
  class ImportBankFileVerificate
    attr_reader :errors

    def initialize(import_bank_file_row, post_date)
      @errors = []
      @import_bank_file_row = import_bank_file_row
      @organization = @import_bank_file_row.organization
      @accounting_period = @organization.accounting_periods
                               .where('accounting_from <= ? AND accounting_to >= ?',
                                      post_date, post_date)
                               .first
      if @accounting_period.nil?
        @errors << "Unable to find accounting period"
        Rails.logger.info "-->>VerificateCreator error accounting period missing"
        return
      end
      @accounting_plan = @accounting_period.accounting_plan
      @verificate_creator = Services::VerificateCreator.new(@accounting_period, @import_bank_file_row)
    end

    def valid?
      errors.empty?
    end

    def create
      Verificate.transaction do
        description = @import_bank_file_row.name.blank? ? 'No name' : @import_bank_file_row.name
        @verificate_creator.save_verificate( @import_bank_file_row.posting_date,
                                             description,
                                             @import_bank_file_row.reference,
                                             @import_bank_file_row.note,
                                             nil,
                                             nil )

        # create payment
        if @import_bank_file_row.amount > 0
          debit = @import_bank_file_row.amount
          credit = 0
        else
          debit = 0
          credit = -@import_bank_file_row.amount
        end
        default_code = default_code(01)
        account = account_from_default_code(default_code)
        @verificate_creator.save_verificate_item(account, debit, credit)
      end
    end

    def default_code(code)
      @organization.default_codes.find_by_code(code)
    end

    def account_from_default_code(default_code)
      @accounting_plan.accounts.find_by_default_code_id(default_code.id)
    end

    def template(template_id)
      template = @organization.templates.find(template_id)
      @verificate_creator.save_verificate( @import_bank_file_row.posting_date,
                                           template.description,
                                           @import_bank_file_row.reference,
                                           @import_bank_file_row.note,
                                           template,
                                           nil )
    end

    def verificate_id
      @verificate_creator.verificate_id
    end
  end
end
