module Job
  class TaxTableEvent
    @queue = :tax_table_events
    def self.perform(tax_table_id, event_name)
      tax_table = TaxTable.find(tax_table_id)
      if TaxTable::VALID_EVENTS.include?(event_name)
        Rails.logger.info "will execute #{event_name} on #{tax_table.id}"
        tax_table.send(event_name)
      else
        Rails.logger.info "** Job::TaxTableEvent unknown event_name(#{event_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::TaxTableEvent could not find ' \
        "object with id #{tax_table_id}"
    end
  end
end
