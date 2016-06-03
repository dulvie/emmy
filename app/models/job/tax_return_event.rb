module Job
  class TaxReturnEvent
    @queue = :tax_retunr_events
    def self.perform(tax_return_id, event_name)
      tax_return = TaxReturn.find(tax_return_id)
      if TaxReturn::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{tax_return.id}"
        tax_return.send(event_name)
      else
        Rails.logger.info "** Job::TaxReturnEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::TaxReturnEvent could not find ' \
        "object with id #{tax_return_id}"
    end
  end
end
