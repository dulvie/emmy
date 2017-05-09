class VatPeriod < ActiveRecord::Base
  # t.string   :name
  # t.datetime :vat_from
  # t.datetime :vat_to
  # t.datetime :deadline
  # t.string   :state
  # t.datetime :calculated_at
  # t.datetime :reported_at
  # t.datetime :closed_at
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :suppier_id

  # t.timestamps

  attr_accessible :name, :vat_from, :vat_to, :accounting_period_id, :deadline,
    :supplier_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :supplier
  has_many :vat_reports, dependent: :destroy
  has_one :verificate

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :vat_from, presence: true
  validates :vat_to, presence: true
  validate :check_to
  validate :overlaping_period
  validates :deadline, presence: true
  VALID_EVENTS = %w(vat_report_event vat_verificate_event)

  def check_to
    if vat_from >= vat_to
      errors.add(:vat_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = VatPeriod
            .where('organization_id = ? and vat_to >= ? and vat_from <= ?' ,
                   organization_id, vat_from, vat_to).count
    if new_record?
      errors.add(:vat_to, I18n.t(:within_period)) if p > 0
    else
      errors.add(:vat_to, I18n.t(:within_period)) if p > 1
    end
  end

  STATE_CHANGES = [:mark_calculated, :mark_reported, :mark_closed]

  def state_change(event, changed_at = nil, user_id = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at, user_id)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_calculated, do: :calculate
    after_transition on: :mark_calculated, do: :enqueue_vat_report
    before_transition on: :mark_reported, do: :report
    after_transition on: :mark_reported, do: :enqueue_verificate
    before_transition on: :mark_closed, do: :close

    event :mark_calculated do
      transition [:preliminary, :calculated] => :start_calculation
    end
    event :finnish_calculation do
      transition start_calculation: :calculated
    end
    event :mark_reported do
      transition calculated: :reported
    end
    event :mark_closed do
      transition reported: :closed
    end
  end

  def calculate(transition)
    self.calculated_at = transition.args[0]
  end

  def report(transition)
    self.reported_at = transition.args[0]
  end

  def enqueue_verificate
    logger.info '** VatPeriod enqueue a job that will create verificate.'
    Resque.enqueue(Job::VatPeriodEvent, id, 'vat_verificate_event')
  end

  # Run from the 'Job::VatPeriodEvent' model
  def vat_verificate_event
    logger.info '** VatPeriod verificate_event start'
    vat_verificate = Services::VatVerificate.new(self, deadline)
    if vat_verificate.create
      logger.info "** VatPeriod #{id} create_verificate returned ok"
    else
      logger.info "** VatPeriod #{id} create_verificate did NOT return ok"
    end
  end

  def close(transition)
    self.closed_at = transition.args[0]
  end

  def enqueue_vat_report
    logger.info '** VatPeriod enqueue a job that will create vat report.'
    Resque.enqueue(Job::VatPeriodEvent, id, 'vat_report_event')
  end

  # Run from the 'Job::VatPeriodEvent' model
  def vat_report_event
    logger.info '** VatPeriod vat_report_event start'
    vat_report_creator = Services::VatReportCreator.new(self)
    vat_report_creator.delete_vat_report
    if vat_report_creator.report
      logger.info "** VatPeriod #{id} vat_report returned ok, marking complete"
      finnish_calculation
    else
      logger.info "** VatPeriod #{id} vat_report did NOT return ok, not marking complete"
    end
  end

  def can_calculate?
    return false if state == 'reported'
    true
  end

  def can_report?
    ['calculated', 'reported'].include? state
  end

  def calculated?
    return true if state == 'calculated'
    false
  end

  def final?
    return true if state == 'final'
    false
  end

  def can_delete?
    return false if vat_reports.size > 0
    true
  end
end
