module Job
  class OpeningBalanceEvent
    @queue = :opening_balance_events
    def self.perform(opening_balance_id, event_name)
      opening_balance = OpeningBalance.find(opening_balance_id)
      if OpeningBalance::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{opening_balance.id}"
        opening_balance.send(event_name)
      else
        Rails.logger.info "** Job::OpeningBalanceEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::ImportBankFileEvent could not find ' \
        "object with id #{opening_balance_id}"
    end
  end
end
