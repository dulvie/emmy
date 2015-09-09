class Job::TableTransactionEvent
  @queue = :table_transaction_events

  def self.perform(table_transaction_id)
    trans = TableTransaction.find(table_transaction_id)
    execute(trans)
  end

  def self.execute(trans)
    Rails.logger.info "-->>TableTransactionEvent.execute(#{trans.inspect})"
    case trans.execute
    when 'tax_table'
      tax_table_creator = Services::TaxTableCreator.new(trans.organization, trans.user)
      tax_table_creator.read_and_save(trans.directory, trans.file_name, trans.year, trans.table)
    else
      Rails.logger.info "-->>#{trans.code} not implemented"
      return
    end
    trans.complete = 'true'
    trans.save
    Rails.logger.info "-->>END TableTransactionEven"
  end
end
