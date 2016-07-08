module Job
  class WagePeriodEvent
    @queue = :wage_period_events
    def self.perform(wage_period_id, event_name)
      wage_period = WagePeriod.find(wage_period_id)
      if WagePeriod::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{wage_period.id}"
        wage_period.send(event_name)
      else
        Rails.logger.info "** Job::WagePeriodEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::WagePeriodEvent could not find ' \
        "object with id #{wage_period_id}"
    end
  end
end
