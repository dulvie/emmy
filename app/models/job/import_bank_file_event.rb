module Job
  class ImportBankFileEvent
    @queue = :import_bank_file_events
    def self.perform(import_bank_file_id, event_name)
      import_bank_file = ImportBankFile.find(import_bank_file_id)
      if ImportBankFile::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{import_bank_file.id}"
        import_bank_file.send(event_name)
      else
        Rails.logger.info "** Job::ImportBankFileEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::ImportBankFileEvent could not find ' \
        "object with id #{import_bank_file_id}"
    end
  end
end
