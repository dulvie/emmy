class Job::BankFileTransactionEvent
  @queue = :bank_file_transaction_events

  def self.perform(transaction_id)
    trans = BankFileTransaction.find(transaction_id)
    run(trans)
  end

  def self.run(trans)
    Rails.logger.info "-->>BankFileTransactionEvent.run(#{trans.inspect})"
    case trans.execute
    when 'import'
      @import_bank_file = Services::ImportBankFileCreator.new(trans.organization, trans.user, trans.directory, trans.file_name)
      @import_bank_file.read_and_save_nordea
    else
      Rails.logger.info "-->>#{trans.execute} not implemented"
    end
    trans.complete = 'true'
    trans.save
    Rails.logger.info "-->>BankFileTransactionEvent.END"
  end
end
