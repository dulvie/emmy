class DefaultCodeHeaderJob < ApplicationJob
  queue_as :default_code_header_jobs

  def perform(default_code_header_id, import_job)
    default_code_header = DefaultCodeHeader.find(default_code_header_id)
    if DefaultCodeHeader::VALID_JOBS.include?(import_job)
      Rails.logger.info "will execute #{import_job} on #{default_code_header.id}"
      default_code_header.send(import_job)
    else
      Rails.logger.info "** Job::DefaultCodeHeaderJob unknown job(#{import_job})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::DefaultCodeHeaderJob could not find ' \
      "object with id #{default_code_header_id}"
  end
end