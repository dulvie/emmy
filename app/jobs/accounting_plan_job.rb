class AccountingPlanJob < ApplicationJob
  @queue = :accounting_plan_jobs
  def perform(accounting_plan_id, job)
    accounting_plan = AccountingPlan.find(accounting_plan_id)
    if AccountingPlan::VALID_JOBS.include?(job)
      Rails.logger.info "will execute #{job} on #{accounting_plan.id}"
      accounting_plan.send(job)
    else
      Rails.logger.info "** Job::AccountingPlanJob unknown job(#{job})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::AccountingPlanJob could not find ' \
      "object with id #{accounting_plan_id}"
  end
end