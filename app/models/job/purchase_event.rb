module Job
  class PurchaseEvent
    @queue = :purchase_events
    def self.perform(purchase_id, event_name)
      purchase = Purchase.find(purchase_id)
      if Purchase::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{purchase.id}"
        purchase.send(event_name)
      else
        Rails.logger.info "** Job::PurchaseEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::PurchaseEvent could not find ' \
        "object with id #{purchase_id}"
    end
  end
end
