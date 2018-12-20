class ClosingBalanceJob < ApplicationJob
  queue_as :closing_balance_jobs

  def perform(closing_balance_id, job_name)
    closing_balance = ClosingBalance.find(closing_balance_id)
    if ClosingBalance::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{closing_balance.id}"
      closing_balance.send(job_name)
    else
      Rails.logger.info "** ClosingBalanceJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** ClosingBalanceJob could not find ' \
      "object with id #{closing_balance_id}"
  end
end