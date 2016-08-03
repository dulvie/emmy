module Job
  class SaleEvent
    @queue = :sale_events
    def self.perform(sale_id, event_name)
      sale = Sale.find(sale_id)
      if Sale::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{sale.id}"
        sale.send(event_name)
      else
        Rails.logger.info "** Job::SaleEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::SaleEvent could not find ' \
        "object with id #{sale_id}"
    end
  end
end
