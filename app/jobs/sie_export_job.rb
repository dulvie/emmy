class SieExportJob < ApplicationJob
  queue_as :sie_export_jobs

  def perform(sie_export_id, job_name)
    sie_export = SieExport.find(sie_export_id)
    if SieExport::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{sie_export.id}"
      sie_export.send(job_name)
    else
      Rails.logger.info "** SieExportJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** SieExportJob could not find ' \
      "object with id #{sie_export_id}"
  end
end