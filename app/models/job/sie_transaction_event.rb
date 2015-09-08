class Job::SieTransactionEvent
  @queue = :sie_transaction_events

  def self.perform(sie_transaction_id)
    trans = SieTransaction.find(sie_transaction_id)
    execute(trans)
  end

  def self.execute(trans)
    Rails.logger.info "-->>SieTransactionEvent.execute(#{trans.inspect})"
    case trans.execute
    when 'import'
      accounting_period = trans.organization.accounting_periods.find(trans.accounting_period_id)
      accounting_plan = accounting_period.accounting_plan
      @import_sie = Services::ImportSie.new(trans.organization, trans.user, trans.directory, trans.file_name, accounting_period, accounting_plan)
      @import_sie.read_and_save(trans.sie_type)
    when 'export'
      accounting_period = trans.organization.accounting_periods.find(trans.accounting_period_id)
      ledger = trans.organization.ledgers.where('accounting_period_id = ? ', trans.accounting_period_id).first
      @export_sie = Services::ExportSie.new(trans.organization, trans.user, trans.directory, trans.file_name, accounting_period, ledger)
      @export_sie.create_file(trans.sie_type)
    else
      Rails.logger.info "-->>#{trans.execute} not implemented"
      return
    end
    trans.complete = 'true'
    trans.save
    Rails.logger.info "-->>END SieTransactionEven"
  end
end
