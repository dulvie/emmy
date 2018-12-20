class ExportBankFileJob < ApplicationJob
  queue_as :export_bank_file_jobs

  def perform(export_bank_file_id, job_name)
    export_bank_file = ExportBankFile.find(export_bank_file_id)
    if ExportBankFile::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{export_bank_file.id}"
      export_bank_file.send(job_name)
    else
      Rails.logger.info "** ExportBankFileJob unknown job_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** ExportBankFileJob could not find ' \
      "object with id #{export_bank_file_id}"
  end
end