module Job
  class ClosingBalanceEvent
    @queue = :closing_balance_events
    def self.perform(closing_balance_id, event_name)
      closing_balance = ClosingBalance.find(closing_balance_id)
      if ClosingBalance::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{closing_balance.id}"
        closing_balance.send(event_name)
      else
        Rails.logger.info "** Job::ClosingBalanceEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::ClosingBalanceEvent could not find ' \
        "object with id #{closing_balance_id}"
    end
  end
end
