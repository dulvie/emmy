class Job::VerificateTransactionEvent
  @queue = :verificate_transaction_events

  def self.perform(verificate_transaction_id)
    trans = VerificateTransaction.find(verificate_transaction_id)
    create_verificate(trans)
  end

  def self.create_verificate(trans)
    Rails.logger.info "-->>VerificateTransactionEvent.create_verificate(#{trans.inspect})"
    @verificate_creator = Services::VerificateCreatorOld.new(trans.organization, trans.user, trans.parent, trans.posting_date)
    unless @verificate_creator.valid?
      Rails.logger.info "unable to create VerificateCreator object:"\
                        "#{@verificate_creator.errors.inspect}"
      return
    end

    case trans.verificate_type
    when 'accounts_receivable'
      @verificate_creator.accounts_receivable
    when 'accounts_receivable_reverse'
      @verificate_creator.accounts_receivable_reverse
    when 'customer_payments'
      @verificate_creator.customer_payments
    when 'accounts_payable'
      @verificate_creator.accounts_payable
    when 'supplier_payments'
      @verificate_creator.supplier_payments
    when 'vat_report'
      @verificate_creator.vat_report
    when 'wage'
      @verificate_creator.wage
    when 'wage_tax'
      @verificate_creator.wage_tax
    when 'stock_value'
      # @verificate_creator.stock_value
    else
      Rails.logger.info "-->>#{trans.verificate_type} not implemented"
    end
    Rails.logger.info "-->>END"
  end
end
