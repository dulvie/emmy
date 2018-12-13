class WagePeriodJob < ApplicationJob
  @queue = :wage_period_jobs
  def perform(wage_period_id, job_name)
    wage_period = WagePeriod.find(wage_period_id)
    if WagePeriod::VALID_EVENTS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{wage_period.id}"
      wage_period.send(job_name)
    else
      Rails.logger.info "** Job::WagePeriodJob unknown event_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::WagePeriodJob could not find ' \
      "object with id #{wage_period_id}"
  end
end

