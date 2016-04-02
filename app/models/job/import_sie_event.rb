module Job
  class ImportSieEvent
    @queue = :import_sie_events
    def self.perform(sie_import_id, import_event)
      sie_import = SieImport.find(sie_import_id)
      if SieImport::VALID_EVENTS.include?(import_event)
        Rails.logger.info "will execute #{import_event} on #{sie_import.id}"
        sie_import.send(import_event)
      else
        Rails.logger.info "** Job::SieImportEvent unknown sie_type(#{import_event})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::SieImportEvent could not find ' \
        "object with id #{sie_import_id}"
    end
  end
end
