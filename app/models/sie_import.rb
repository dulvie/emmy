class SieImport < ActiveRecord::Base
  # t.datetime :import_date
  # t.string   :sie_type
  # t.string   :state
  # t.attachment :upload
  # t.integer  :organization_id
  # t.integer  :user_id
  # t.integer  :accounting_period_id
  # t.timestamps

  VALID_JOBS = %w(import_job)
  SIE_TYPES = %w(IB UB Transactions)

  #attr_accessible :import_date, :sie_type, :accounting_period_id, :upload

  has_attached_file :upload
  belongs_to :organization
  belongs_to :user
  belongs_to :accounting_period

  validates_presence_of :organization_id
  validates_presence_of :user_id
  validates_presence_of :upload
  validates_attachment_content_type :upload, content_type: %w(text/plain)
  validate :check_ib, on: :create
  validate :check_ub, on: :create
  validate :check_transactions, on: :create

  after_commit :enqueue_import_job, on: :create

  def check_ib
    return true if sie_type != 'IB'
    return true if accounting_period.opening_balance.nil?
    errors.add(:sie_type, I18n.t(:already_exists))
  end

  def check_ub
    return true if sie_type != 'UB'
    return true if accounting_period.closing_balance.nil?
    errors.add(:sie_type, I18n.t(:already_exists))
  end

  def check_transactions
    return true if sie_type != 'Transactions'
    return true if accounting_period.verificates.nil?
    errors.add(:sie_type, I18n.t(:already_exists))
  end

  def can_delete?
    true
  end

  def enqueue_import_job
    if completed?
      logger.info "** SieImport #{id} already completed, will not enqueue_job"
      return
    end
    logger.info '** SieImport enqueue a job that will parse the imported file.'
    SieImportJob.perform_later(id, 'import_job')
  end

  # Run from the 'Job::SieImportJob' model
  def import_job
    return nil if completed?
    logger.info '** SieImport start'
    parse_and_import = Services::ImportSie.new(self)
    logger.info '** SieImport start - 1'
    if parse_and_import.read_and_save(sie_type)
      logger.info "** SieImport #{id} parse/import returned ok, marking complete"
      complete
    else
      logger.info "** SieImport #{id} parse/import did NOT return ok, not marking complete"
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
