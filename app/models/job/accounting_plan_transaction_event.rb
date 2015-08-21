class Job::AccountingPlanTransactionEvent
  @queue = :accounting_plan_transaction_events

  def self.perform(transaction_id)
    trans = AccountingPlanTransaction.find(transaction_id)
    run(trans)
  end

  def self.run(trans)
    Rails.logger.info "-->>AccountingPlanTransactionEvent.run(#{trans.inspect})"

    case trans.execute
    when 'import'
      @accounting_plan_creator = Services::AccountingPlanCreator.new(trans.organization, trans.user)
      @accounting_plan_creator.read_and_save(trans.directory, trans.file)
    when 'disable'
      @accounting_plan_creator = Services::AccountingPlanCreator.new(trans.organization, trans.user)
      @accounting_plan_creator.set_accounting_plan(trans.accounting_plan_id)
      @accounting_plan_creator.BAS_set_active(trans.directory, trans.file)
    else
      Rails.logger.info "-->>#{trans.execute} not implemented"
    end
    Rails.logger.info "-->>END"
  end
end
