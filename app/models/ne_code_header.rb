class NeCodeHeader < ActiveRecord::Base
  # t.string   :name
  # t.string   :file_name
  # t.string   :run_type
  # t.string   :status
  # t.integer  :accounting_plan_id
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :file_name, :run_type, :accounting_plan_id

  belongs_to :organization
  belongs_to :accounting_plan

  validates_presence_of :name
  validates_presence_of :organization_id
  validate :check_file_name
  VALID_EVENTS = %w(import_event)

  def check_file_name
    file_importer = FileImporter.new(DIRECTORY, nil, nil)
    files = file_importer.files(FILES)
    errors.add(:file_name, I18n.t(:name_error)) if !files.include?(file_name)
  end

  after_commit :enqueue_import_event, on: :create

  DIRECTORY = 'files/codes/'
  FILES = 'NE*.csv'

  def can_delete?
    false
  end

  def enqueue_import_event
    logger.info '** NeCodeHeader enqueue a job that will parse the imported file.'
    create
    Resque.enqueue(Job::NeCodeHeaderEvent, id, 'import_event')
  end

  # Run from the 'Job::NeCodeHeaderEvent' model
  def import_event
    @ne_codes = organization.ne_codes
    ne_code_creator = Services::NeCodeCreator.new(organization, @ne_codes, accounting_plan)
    if ne_code_creator.execute(run_type, DIRECTORY, file_name)
      logger.info "** NeCodeHeader #{id} import codes returned ok, marking complete"
      complete
    else
      logger.info "** NeCodeHeader #{id} import did NOT return ok, not marking complete"
    end
  end

  state_machine :state, initial: :created do
    event :complete do
      transition created: :completed
    end
    event :create do
      transition complete: :created
    end
  end
end
