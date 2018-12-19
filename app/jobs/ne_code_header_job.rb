class NeCodeHeaderJob < ApplicationJob
  @queue = :ne_code_header_jobs
  def perform(ne_code_header_id, import_job)
    ne_code_header = NeCodeHeader.find(ne_code_header_id)
    if NeCodeHeader::VALID_JOBS.include?(import_job)
      Rails.logger.info "will execute #{import_job} on #{ne_code_header.id}"
      ne_code_header.send(import_job)
    else
      Rails.logger.info "** Job::NeCodeHeaderJob unknown job(#{import_job})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::NeCodeHeaderJob could not find ' \
      "object with id #{ne_code_header_id}"
  end
end