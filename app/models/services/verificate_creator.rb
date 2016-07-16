module Services
  class VerificateCreator
    attr_reader :errors

    def initialize(accounting_period, object)
      @errors = []
      @accounting_period = accounting_period
      @organization = @accounting_period.organization
      @object = object
    end

    def valid?
      errors.empty?
    end

    def verificate_id
      @verificate.id
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
      @verificate.import_bank_file_row_id = @object.id if @object.class.name == 'ImportBankFileRow'
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
