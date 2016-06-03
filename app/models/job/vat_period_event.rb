module Job
  class VatPeriodEvent
    @queue = :vat_period_events
    def self.perform(vat_period_id, event_name)
      vat_period = VatPeriod.find(vat_period_id)
      if VatPeriod::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{vat_period.id}"
        vat_period.send(event_name)
      else
        Rails.logger.info "** Job::VatPeriodEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::VatPeriodEvent could not find ' \
        "object with id #{vat_period_id}"
    end
  end
end
