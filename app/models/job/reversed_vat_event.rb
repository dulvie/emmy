module Job
  class ReversedVatEvent
    @queue = :reversed_vat_events
    def self.perform(reversed_vat_id, event_name)
      reversed_vat = ReversedVat.find(reversed_vat_id)
      if ReversedVat::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{reversed_vat.id}"
        reversed_vat.send(event_name)
      else
        Rails.logger.info "** Job::ReverseVatEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::ReversedVatEvent could not find ' \
        "object with id #{reversed_vat_id}"
    end
  end
end
