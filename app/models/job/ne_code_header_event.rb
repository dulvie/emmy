module Job
  class NeCodeHeaderEvent
    @queue = :ne_code_header_events
    def self.perform(ne_code_header_id, import_event)
      ne_code_header = NeCodeHeader.find(ne_code_header_id)
      if NeCodeHeader::VALID_EVENTS.include?(import_event)
        Rails.logger.info "will execute #{import_event} on #{ne_code_header.id}"
        ne_code_header.send(import_event)
      else
        Rails.logger.info "** Job::NeCodeHeaderEvent unknown event(#{import_event})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::NeCodeHeaderEvent could not find ' \
        "object with id #{ne_code_header_id}"
    end
  end
end
