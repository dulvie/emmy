class Job::BalanceTransactionEvent
  @queue = :balance_transaction_events

  def self.perform(transaction_id)
    trans = BalanceTransaction.find(transaction_id)
    run(trans)
  end

  def self.run(trans)
    Rails.logger.info "-->>BalanceTransactionEvent.run(#{trans.inspect})"
    case trans.execute
    when 'opening'
      # Opening balance is created from UB
      @opening_balance_creator = Services::OpeningBalanceCreator.new(trans.organization, trans.user, trans.parent, trans.accounting_period)
      @opening_balance_creator.add_from_ub
    when 'closing'
      # Closing balance is created from ledger (verificate summery)
      @closing_balance_creator = Services::ClosingBalanceCreator.new(trans.organization, trans.user, trans.parent, trans.accounting_period)
      @closing_balance_creator.update_from_ledger
    else
      Rails.logger.info "-->>#{trans.execute} not implemented"
    end
    trans.complete = 'true'
    trans.save
    Rails.logger.info "-->>BalanceTransactionEvent.END"
  end
end
