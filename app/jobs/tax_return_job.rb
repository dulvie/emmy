class TaxReturnJob < ApplicationJob
  queue_as :tax_return_jobs

  def perform(tax_return_id, job_name)
    tax_return = TaxReturn.find(tax_return_id)
    if TaxReturn::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{tax_return.id}"
      tax_return.send(job_name)
    else
      Rails.logger.info "** Job::TaxReturnJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::TaxReturnJob could not find ' \
      "object with id #{tax_return_id}"
  end
end