class PurchaseJob < ApplicationJob
  queue_as :purchase_jobs

  def perform(purchase_id, job_name)
    purchase = Purchase.find(purchase_id)
    if Purchase::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{purchase.id}"
      purchase.send(job_name)
    else
      Rails.logger.info "** PurchaseJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** PurchaseJob could not find ' \
      "object with id #{purchase_id}"
  end
end