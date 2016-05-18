class AccountingPlan < ActiveRecord::Base
  # t.string   :name
  # t.string   :description
  # t.string   :file_name
  # t.string   :state
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :description, :file_name

  belongs_to :organization
  has_many :accounting_classes, dependent: :destroy
  has_many :accounting_groups, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :accounting_periods

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  VALID_EVENTS = %w(import_event)

  DIRECTORY = 'files/accounting_plans/'
  FILES = '*.csv'

  after_commit :enqueue_import_event, on: :create

  def self.validate_file(import_file)
    file_importer = FileImporter.new(DIRECTORY, nil, nil)
    files = file_importer.files(FILES)
    files.include?(import_file)
  end

  def disable_accounts?
    return true if file_name && file_name.include?('Normal')
    false
  end

  def enqueue_import_event
    if completed?
      logger.info "** AccountingPlan #{id} already completed, will not enqueue_event"
      return
    end
    logger.info '** AccountingPlan enqueue a job that will parse the imported file.'
    Resque.enqueue(Job::AccountingPlanEvent, id, 'import_event')
  end

  # Run from the 'Job::ImportSieEvent' model
  def import_event
    return nil if completed?
    logger.info '** AccountingPlan import_event start'
    accounting_plan_creator = Services::AccountingPlanCreator.new(self)
    logger.info '** AccountingPlan start - 1'
    if accounting_plan_creator.read_and_save(DIRECTORY, file_name)
      logger.info "** AccountingPlan #{id} import returned ok, marking complete"
      complete
    else
      logger.info "** AccountingPlan #{id} import did NOT return ok, not marking complete"
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

  def can_delete?
    return false if accounting_periods.size > 0
    true
  end
end
