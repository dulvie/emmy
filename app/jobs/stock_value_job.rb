class StockValueJob < ApplicationJob
  @queue = :stock_value_jobs
  def perform(stock_value_id, job_name, post_date)
    stock_value = StockValue.find(stock_value_id)
    if StockValue::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{stock_value.id}"
      stock_value.send(job_name, post_date)
    else
      Rails.logger.info "** Job::StockValueJob unknown event_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::StockValueJob could not find ' \
      "object with id #{stock_value_id}"
  end
end