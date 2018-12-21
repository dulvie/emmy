class SaleJob < ApplicationJob
  queue_as :sale_jobs

  def perform(sale_id, job_name)
    sale = Sale.find(sale_id)
    if Sale::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{sale.id}"
      sale.send(job_name)
    else
      Rails.logger.info "** SaleJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** SaleJob could not find ' \
      "object with id #{sale_id}"
  end
end