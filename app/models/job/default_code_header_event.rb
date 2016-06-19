module Job
  class DefaultCodeHeaderEvent
    @queue = :default_code_header_events
    def self.perform(default_code_header_id, import_event)
      default_code_header = DefaultCodeHeader.find(default_code_header_id)
      if DefaultCodeHeader::VALID_EVENTS.include?(import_event)
        Rails.logger.info "will execute #{import_event} on #{default_code_header.id}"
        default_code_header.send(import_event)
      else
        Rails.logger.info "** Job::DefaultCodeHeaderEvent unknown event(#{import_event})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::DefaultCodeHeaderEvent could not find ' \
        "object with id #{default_code_header_id}"
    end
  end
end
