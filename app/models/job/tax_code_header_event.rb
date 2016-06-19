module Job
  class TaxCodeHeaderEvent
    @queue = :tax_code_header_events
    def self.perform(tax_code_header_id, import_event)
      tax_code_header = TaxCodeHeader.find(tax_code_header_id)
      if TaxCodeHeader::VALID_EVENTS.include?(import_event)
        Rails.logger.info "will execute #{import_event} on #{tax_code_header.id}"
        tax_code_header.send(import_event)
      else
        Rails.logger.info "** Job::TaxCodeHeaderEvent unknown event(#{import_event})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::TaxCodeHeaderEvent could not find ' \
        "object with id #{tax_code_header_id}"
    end
  end
end
