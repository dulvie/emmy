class VerificateJob < ApplicationJob
  @queue = :verificate_jobs
  def perform(verificate_id, job_name)
    verificate = Verificate.find(verificate_id)
    if Verificate::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{verificate.id}"
      verificate.send(job_name)
    else
      Rails.logger.info "** Job::VerificateJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** Job::VerificateJob could not find ' \
      "object with id #{verificate_id}"
  end
end