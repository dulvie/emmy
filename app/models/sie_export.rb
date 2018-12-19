class SieExport < ActiveRecord::Base
  # t.datetime :export_date
  # t.datetime :sie_type
  # t.string   :state
  # t.attachment :download
  # t.integer  :accounting_period_id
  # t.integer  :organization_id
  # t.integer  :user_id
  # t.timestamps

  #attr_accessible :export_date, :sie_type, :accounting_period, :accounting_period_id, :download

  VALID_JOBS = %w(export_job)
  SIE_TYPES =  ['Bokslutssaldon (1)', 'Periodsaldon (2)', 'Objektsaldon (3)', 'Transaktioner (4)']

  has_attached_file :download
  belongs_to :accounting_period
  belongs_to :organization
  belongs_to :user

  validates_presence_of :export_date
  validates_presence_of :sie_type
  validates_presence_of :organization_id
  validates_presence_of :user_id
  validates_attachment_content_type :download, content_type: ['text/plain']
  validate :check_balances

  def check_balances
    if :sie_type == SIE_TYPES[0] && accounting_period.closing_balance.size == 0
      errors.add(:sie_type, I18n.t(:closing_balance_not_set))
    end
  end

  after_commit :enqueue_export_job, on: :create

  def tmp_file
    # download.path
    "#{organization.slug}_sieexport_#{id}"
  end

  def can_delete?
    true
  end

  def enqueue_export_job
    if completed?
      logger.info "** SieExport #{id} already completed, will not enqueue_job"
      return
    end
    logger.info '** SieExport enqueue a job that will create a sie file.'
    SieExportJob.perform_later(id, 'export_job')
  end

  # Run from the 'SieExportJob' model
  def export_job
    return nil if completed?
    export_sie = Services::ExportSie.new(self)
    if export_sie.create_file(sie_type)
      logger.info "** sie_export #{id} create_file returned ok, marking complete"
      complete
    else
      logger.info "** sie_export #{id} create_file did NOT return ok, not marking complete"
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
