class ExportBankFile < ActiveRecord::Base
  # t.datetime :export_date
  # t.datetime :from_date
  # t.datetime :to_date
  # t.string   :reference
  # t.string   :pay_account
  # t.string   :organization_number
  # t.string   :iban
  # t.string   :state
  # t.attachment :download
  # t.integer  :organization_id
  # t.integer  :user_id
  # t.timestamps

  #attr_accessible :export_date, :from_date, :to_date, :reference, :pay_account,
  #                :organization_number, :iban, :download

  belongs_to :organization
  belongs_to :user
  has_many   :export_bank_file_rows, dependent: :delete_all
  has_attached_file :download

  validates :from_date, presence: true
  validates :to_date, presence: true
  validates_attachment_content_type :download, content_type: ['text/plain']


  VALID_JOBS = %w(export_job)
  TYPES = ['Fakturabetalning', 'Löneutbetalning']

  after_commit :enqueue_export_job, on: :create

  def enqueue_export_job
    if completed?
      logger.info "** ExportBankFile #{id} already completed, will not enqueue_job"
      return
    end
    logger.info '** ExportBankFile enqueue a job that will create a export file.'
    ExportBankFileJob.perform_later(id, 'export_job')
  end

  # Run from the 'ExportBankFileJob' model
  def export_job
    return nil if completed?
    export_bank_file = Services::ExportBankFileCreator.new(self)
    if export_bank_file.read_and_create_file
      logger.info "** ExportBankFile #{id} read_and_create returned ok, marking complete"
      complete
    else
      logger.info "** ImportBankFile #{id} parse/import did NOT return ok, not marking complete"
    end
  end

  def file_name
    return "#{organization.slug}_payment_bank_file_#{id}" if self.reference == TYPES[0]
    return "#{organization.slug}_wage_bank_file_#{id}" if self.reference == TYPES[1]
    return nil
  end

  def can_delete?
    true
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
