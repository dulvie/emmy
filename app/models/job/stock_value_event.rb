module Job
  class StockValueEvent
    @queue = :stock_value_events
    def self.perform(stock_value_id, event_name, post_date)
      stock_value = StockValue.find(stock_value_id)
      if StockValue::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{stock_value.id}"
        stock_value.send(event_name, post_date)
      else
        Rails.logger.info "** Job::StockValueEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::StockValueEvent could not find ' \
        "object with id #{stock_value_id}"
    end
  end
end
