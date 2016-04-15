module Job
  class ExportBankFileEvent
    @queue = :export_bank_file_events
    def self.perform(export_bank_file_id, event_name)
      export_bank_file = ExportBankFile.find(export_bank_file_id)
      if ExportBankFile::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{export_bank_file.id}"
        export_bank_file.send(event_name)
      else
        Rails.logger.info "** Job::ExportBankFileEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::ExportBankFileEvent could not find ' \
        "object with id #{export_bank_file_id}"
    end
  end
end
