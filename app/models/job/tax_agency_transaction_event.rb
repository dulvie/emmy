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
      @vat_report_creator = Services::VatReportCreator.new(trans.organization, trans.user, trans.parent)
      @vat_report_creator.delete_vat_report
      @vat_report_creator.report
    when 'tax'
      @tax_return_report_creator = Services::TaxReturnReportCreator.new(trans.organization, trans.user, trans.parent)
      @tax_return_report_creator.delete_report
      @tax_return_report_creator.report
    else
      Rails.logger.info "-->>#{trans.report_type} not implemented"
    end
    Rails.logger.info "-->>END"
  end
end
