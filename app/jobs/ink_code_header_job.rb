class InkCodeHeaderJob < ApplicationJob
  queue_as :ink_code_header_jobs

  def perform(ink_code_header_id, import_job)
    ink_code_header = InkCodeHeader.find(ink_code_header_id)
    if InkCodeHeader::VALID_JOBS.include?(import_job)
      Rails.logger.info "will execute #{import_job} on #{ink_code_header.id}"
      ink_code_header.send(import_job)
    else
      Rails.logger.info "** Job::InkCodeHeaderJob unknown job(#{import_job})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::InkCodeHeaderJob could not find ' \
      "object with id #{ink_code_header_id}"
  end
end