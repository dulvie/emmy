class Job::VerificateTransactionEvent
  @queue = :verificater_transaction_events

  def self.perform(verificate_transaction_id)
    Rails.logger.info "-->>VerificateTransactionEvent.perform(#{verificate_transaction_id})"
    trans = VerificateTransaction.find(verificate_transaction_id)
    create_verificate(trans)
  end

  def self.create_verificate(trans)
    Rails.logger.info "-->>VerificateTransactionEvent.create_verificate(#{trans.inspect})"
    case trans.verificate_type
    when 'accounts_receivable'
      sale = trans.organization.sale.find(trans.parent_id)
      verificate_creator = Services::VerificateCreator.new(trans.organization, trans.user, sale)
      verificate_creator.accounts_receivable
    when 'customer_pyments'
    else
      Rails.logger.info "-->>#{trans.verificate_type} not implemented"
    end

  end
end
