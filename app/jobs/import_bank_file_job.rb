class ImportBankFileJob < ApplicationJob
  queue_as :import_bank_file_jobs

  def perform(import_bank_file_id, job_name)
    import_bank_file = ImportBankFile.find(import_bank_file_id)
    if ImportBankFile::VALID_JOBS.include?(job_name)
      Rails.logger.info "will execute #{job_name} on #{import_bank_file.id}"
      import_bank_file.send(job_name)
    else
      Rails.logger.info "** ImportBankFileJob unknown event_name(#{job_name})"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info '** ImportBankFileJob could not find ' \
      "object with id #{import_bank_file_id}"
  end
end