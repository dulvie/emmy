class Job::WageTransactionEvent
  @queue = :wage_transaction_events

  def self.perform(wage_transaction_id)
    trans = WageTransaction.find(wage_transaction_id)
    execute(trans)
  end

  def self.execute(trans)
    Rails.logger.info "-->>WageTransactionEvent.execute(#{trans.inspect})"
    case trans.execute
    when 'wage_calculate'
      wage_creator = Services::WageCreator.new(trans.organization, trans.user, trans.wage_period)
      wage_creator.delete_wages
      wage_creator.save_wages
    else
      Rails.logger.info "-->>#{trans.code} not implemented"
      return
    end
    trans.complete = 'true'
    trans.save
    Rails.logger.info "-->>END WageTransactionEven"
  end
end
