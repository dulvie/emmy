module Job
  class InkCodeHeaderEvent
    @queue = :ink_code_header_events
    def self.perform(ink_code_header_id, import_event)
      ink_code_header = InkCodeHeader.find(ink_code_header_id)
      if InkCodeHeader::VALID_EVENTS.include?(import_event)
        Rails.logger.info "will execute #{import_event} on #{ink_code_header.id}"
        ink_code_header.send(import_event)
      else
        Rails.logger.info "** Job::InkCodeHeaderEvent unknown event(#{import_event})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::InkCodeHeaderEvent could not find ' \
        "object with id #{ink_code_header_id}"
    end
  end
end
