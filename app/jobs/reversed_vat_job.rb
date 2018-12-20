class ReversedVatJob < ApplicationJob
  queue_as :reversed_vat_jobs

  def perform(reversed_vat_id, job_name)
    reversed_vat = ReversedVat.find(reversed_vat_id)
    if ReversedVat::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{reversed_vat.id}"
      reversed_vat.send(job_name)
    else
      Rails.logger.info "** ReverseVatJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** ReversedVatJob could not find ' \
      "object with id #{reversed_vat_id}"
  end
end