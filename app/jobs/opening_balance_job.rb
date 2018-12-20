class OpeningBalanceJob < ApplicationJob
  queue_as :opening_balance_jobs

  def perform(opening_balance_id, job_name)
    opening_balance = OpeningBalance.find(opening_balance_id)
    if OpeningBalance::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{opening_balance.id}"
      opening_balance.send(job_name)
    else
      Rails.logger.info "** OpeningBalanceJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** OpeningBalanceJob could not find ' \
      "object with id #{opening_balance_id}"
  end
end

