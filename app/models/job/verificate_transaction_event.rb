class Job::VerificateTransactionEvent
  @queue = :verificater_transaction_events

  def self.perform(verificate_transaction_id)
    trans = VerificateTransaction.find(verificate_transaction_id)
    create_verificate(trans)
  end

  def self.create_verificate(trans)
    Rails.logger.info "-->>VerificateTransactionEvent.create_verificate(#{trans.inspect})"
    @verificate_creator = Services::VerificateCreator.new(trans.organization, trans.user, trans.parent, trans.posting_date)
    return if @verificate_creator.nil?

    case trans.verificate_type
    when 'accounts_receivable'
      @verificate_creator.accounts_receivable
    when 'accounts_receivable_reverse'
      @verificate_creator.accounts_receivable_reverse
    when 'customer_payments'
      @verificate_creator.customer_payments
    else
      Rails.logger.info "-->>#{trans.verificate_type} not implemented"
    end
    Rails.logger.info "-->>END"
  end
end
