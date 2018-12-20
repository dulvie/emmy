  class TaxTableJob < ApplicationJob
    queue_as :tax_table_jobs

    def perform(tax_table_id, job_name)
      tax_table = TaxTable.find(tax_table_id)
      if TaxTable::VALID_JOBS.include?(job_name)
        Rails.logger.info "will execute #{job_name} on #{tax_table.id}"
        tax_table.send(job_name)
      else
        Rails.logger.info "** Job::TaxTableJob unknown event_name(#{job_name})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::TaxTableJob could not find ' \
        "object with id #{tax_table_id}"
    end
  end