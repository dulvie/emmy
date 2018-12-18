class TaxCodeHeaderJob < ApplicationJob
  @queue = :tax_code_header_jobs
  def perform(tax_code_header_id, import_job)
    tax_code_header = TaxCodeHeader.find(tax_code_header_id)
    if TaxCodeHeader::VALID_EVENTS.include?(import_job)
      Rails.logger.info "will execute #{import_job} on #{tax_code_header.id}"
      tax_code_header.send(import_job)
    else
      Rails.logger.info "** Job::TaxCodeHeaderJob unknown event(#{import_job})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::TaxCodeHeaderJob could not find ' \
      "object with id #{tax_code_header_id}"
    end
end