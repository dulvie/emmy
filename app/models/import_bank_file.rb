class ImportBankFile < ActiveRecord::Base
  # t.string   :name
  # t.datetime :import_date
  # t.datetime :from_date
  # t.datetime :to_date
  # t.string   :reference
  # t.integer  :organization_id
  # t.integer  :user_id
  # t.string   :state
  # t.timestamps

  VALID_JOBS = %w(import_job)

  #attr_accessible :import_date, :from_date, :to_date, :reference, :upload

  has_attached_file :upload
  belongs_to :organization
  belongs_to :user
  has_many :import_bank_file_rows, dependent: :destroy

  validates_attachment_presence :upload
  validates_attachment_content_type :upload, content_type: ['text/plain', 'text/csv', 'application/vnd.ms-excel']
  validates_presence_of :organization_id
  validates_presence_of :user_id

  after_commit :enqueue_import_job, on: :create

  def name
    'Nordea'
  end

  def can_delete?
    return true if import_bank_file_rows.size == 0
    (completed?)
  end

  def enqueue_import_job
    if completed?
      logger.info "** ImportBankFile #{id} already completed, will not enqueue_job"
      return
    end
    logger.info '** ImportBankFile enqueue a job that will parse the imported file.'
    ImportBankFileJob.perform_later(id, 'import_job')
  end

  # Run from the 'ImportBankFileJob' model
  def import_job
    return nil if completed?
    parse_and_import = Services::ImportBankFileCreator.new(self)
    if parse_and_import.read_and_save_nordea
      logger.info "** ImportBankFile #{id} parse/import returned ok, marking complete"
      complete
    else
      logger.info "** ImportBankFile #{id} parse/import did NOT return ok, not marking complete"
    end
  end

  state_machine :state, initial: :created do
    event :complete do
      transition created: :completed
    end
  end

  def completed?
    state.eql? 'completed'
  end
end
