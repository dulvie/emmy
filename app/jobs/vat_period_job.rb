class VatPeriodJob < ApplicationJob
  @queue = :vat_period_jobs
  def perform(vat_period_id, job_name)
    vat_period = VatPeriod.find(vat_period_id)
    if VatPeriod::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{vat_period.id}"
      vat_period.send(job_name)
    else
      Rails.logger.info "** Job::VatPeriodJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::VatPeriodJob could not find ' \
      "object with id #{vat_period_id}"
  end
end
