class TaxTable < ActiveRecord::Base
  # t.string   :name
  # t.string   :file_name
  # t.integer  :year
  # t.string   :table_name
  # t.string   :state
  # t.integer  :organization_id

  # t.timestamps

  attr_accessible :name, :file_name, :year, :table_name

  belongs_to :organization
  has_many :tax_table_rows, dependent: :destroy
  has_many :employees

  TABLES = *(29..40)
  COLUMNS = ['1', '2', '3', '4', '5', '6']

  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validate  :validate_file

  VALID_EVENTS = %w(import_event destroy_event)

  after_commit :enqueue_import_event, on: :create

  DIRECTORY = 'files/codes/'
  FILES = 'allm*.csv'

  def validate_file
    file_importer = FileImporter.new(DIRECTORY, nil, nil)
    files = file_importer.files(FILES)
    files.include?(file_name)
  end

  def calculate(wage, column)
    return 0 if wage <= 0
    row = tax_table_rows.where('from_wage <= ? AND to_wage >= ?', wage, wage).first
    row.tax(wage, column)
  end

  def can_delete?
    return false if employees.size > 0
    true
  end

  def enqueue_import_event
    if completed?
      logger.info "** TaxTable #{id} already completed, will not enqueue_event"
      return
    end
    logger.info '** TaxTable enqueue a job that will parse the imported file.'
    Resque.enqueue(Job::TaxTableEvent, id, 'import_event')
  end

  # Run from the 'Job::TaxTableEvent' model
  def import_event
    return nil if completed?
    tax_table = Services::TaxTableCreator.new(self)
    if tax_table.read_and_save(DIRECTORY, file_name, table_name)
      logger.info "** TaxTable #{id} parse/import returned ok, marking complete"
      complete
    else
      logger.info "** TaxTable #{id} parse/import did NOT return ok, not marking complete"
    end
  end

  def background_destroy
    logger.info '** TaxTable enqueue a job that will destroy all.'
    mark_deleted
    Resque.enqueue(Job::TaxTableEvent, id, 'destroy_event')
  end

  # Run from the 'Job::TaxTableEvent' model
  def destroy_event
    logger.info '** TaxTable destroy_event start'
    destroy
    logger.info "** TaxTable destroy_event finnish"
  end

  state_machine :state, initial: :created do
    event :complete do
      transition created: :completed
    end
    event :mark_deleted do
      transition completed: :deleted
    end
  end
end
