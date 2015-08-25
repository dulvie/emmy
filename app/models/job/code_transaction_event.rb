class Job::CodeTransactionEvent
  @queue = :code_transaction_events

  def self.perform(code_transaction_id)
    trans = CodeTransaction.find(code_transaction_id)
    execute(trans)
  end

  def self.execute(trans)
    Rails.logger.info "-->>CodeTransactionEvent.execute(#{trans.inspect})"
    case trans.code
    when 'default'
      @default_codes = trans.organization.default_codes
      default_code_creator = Services::DefaultCodeCreator.new(trans.organization, trans.user, @default_codes, trans.accounting_plan)
      default_code_creator.execute(trans.run_type, trans.directory, trans.file)
    when 'ink'
      @ink_codes = trans.organization.ink_codes
      ink_code_creator = Services::InkCodeCreator.new(trans.organization, trans.user, @ink_codes, trans.accounting_plan)
      ink_code_creator.execute(trans.run_type, trans.directory, trans.file)
    when 'ne'
      @ne_codes = trans.organization.ne_codes
      ne_code_creator = Services::NeCodeCreator.new(trans.organization, trans.user, @ne_codes, trans.accounting_plan)
      ne_code_creator.execute(trans.run_type, trans.directory, trans.file)
    when 'tax'
      @tax_codes = trans.organization.tax_codes
      tax_code_creator = Services::TaxCodeCreator.new(trans.organization, trans.user, @tax_codes, trans.accounting_plan)
      tax_code_creator.execute(trans.run_type, trans.directory, trans.file)
    else
      Rails.logger.info "-->>#{trans.code} not implemented"
    end
    Rails.logger.info "-->>END CodeTransactionEven"
  end
end
