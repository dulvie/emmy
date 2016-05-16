module Job
  class ExportSieEvent
    @queue = :export_sie_events
    def self.perform(sie_export_id, event_name)
      sie_export = SieExport.find(sie_export_id)
      if SieExport::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{sie_export.id}"
        sie_export.send(event_name)
      else
        Rails.logger.info "** Job::ImportBankFileEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::ExportSieEvent could not find ' \
        "object with id #{sie_export_id}"
    end
  end
end
