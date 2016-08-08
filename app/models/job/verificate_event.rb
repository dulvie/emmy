module Job
  class VerificateEvent
    @queue = :verificate_events
    def self.perform(verificate_id, event_name)
      verificate = Verificate.find(verificate_id)
      if Verificate::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{verificate.id}"
        verificate.send(event_name)
      else
        Rails.logger.info "** Job::VerificateEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::VerificateEvent could not find ' \
        "object with id #{verificate_id}"
    end
  end
end
