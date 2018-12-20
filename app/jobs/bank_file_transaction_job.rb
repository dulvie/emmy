class BankFileTransactionJob < ApplicationJob
  queue_as :bank_file_transaction_jobs

  def perform(transaction_id)
    trans = BankFileTransaction.find(transaction_id)
    run(trans)
  end

  def run(trans)
    Rails.logger.info "-->>BankFileTransactionEvent.run(#{trans.inspect})"
    case trans.execute
    when 'import'
      @import_bank_file = Services::ImportBankFileCreator.new(trans.organization, trans.user, trans.directory, trans.file_name)
      @import_bank_file.read_and_save_nordea
    when 'export'
      @export_bank_file = trans.organization.export_bank_files.find(trans.parent_id)
      @export_bank_file_creator = Services::ExportBankFileCreator.new(trans.organization, trans.user, @export_bank_file)
      @export_bank_file_creator.read_verificates_and_create_rows if @export_bank_file.reference == 'Fakturabetalning'
      @export_bank_file_creator.read_wages_and_create_rows if @export_bank_file.reference == 'Löneutbetalning'
      @export_bank_file_creator.remove_files
      @export_bank_file_creator.create_file_PO3
      # testfile @export_bank_file_creator.test_file_PO3
    else
      Rails.logger.info "-->>#{trans.execute} not implemented"
    end
    trans.complete = 'true'
    trans.save
    Rails.logger.info "-->>BankFileTransactionEvent.END"
  end
end
