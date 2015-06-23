class Job::TaxAgencyTransactionEvent
  @queue = :tax_agency_transaction_events

  def self.perform(transaction_id)
    trans = TaxAgencyTransaction.find(transaction_id)
    create_report(trans)
  end

  def self.create_report(trans)
    Rails.logger.info "-->>TaxAgencyTransactionEvent.create_report(#{trans.inspect})"

    case trans.report_type
    when 'wage'
      @wage_report_creator = Services::WageReportCreator.new(trans.organization, trans.user, trans.parent)
      @wage_report_creator.delete_wage_report
      @wage_report_creator.report
    when 'vat'

    when 'tax'


    else
      Rails.logger.info "-->>#{trans.report_type} not implemented"
    end
    Rails.logger.info "-->>END"
  end
end
