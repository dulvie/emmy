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

  VALID_EVENTS = %w(import_event)

  attr_accessible :import_date, :from_date, :to_date, :reference, :upload

  has_attached_file :upload
  belongs_to :organization
  belongs_to :user
  has_many :import_bank_file_rows, dependent: :destroy

  validates_attachment_content_type :upload, content_type: ['text/csv']
  validates_presence_of :organization_id
  validates_presence_of :user_id

  after_commit :enqueue_import_event, on: :create

  def name
    'Nordea'
  end

  def can_delete?
    (!completed?)
  end

  def enqueue_import_event
    if completed?
      logger.info "** ImportBankFile #{id} already completed, will not enqueue_event"
      return
    end
    logger.info '** ImportBankFile enqueue a job that will parse the imported file.'
    Resque.enqueue(Job::ImportBankFileEvent, id, 'import_event')
  end

  # Run from the 'Job::ImportBankFile' model
  def import_event
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
