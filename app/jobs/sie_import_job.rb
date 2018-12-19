class SieImportJob < ApplicationJob
  @queue = :import_sie_jobs
  def perform(sie_import_id, import_job)
    sie_import = SieImport.find(sie_import_id)
    if SieImport::VALID_JOBS.include?(import_job)
      Rails.logger.info "will execute #{import_job} on #{sie_import.id}"
      sie_import.send(import_job)
    else
      Rails.logger.info "** SieImportJob unknown sie_type(#{import_job})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** SieImportJob could not find ' \
      "object with id #{sie_import_id}"
  end
end