class ReversedVat < ActiveRecord::Base

  # t.string   :name
  # t.datetime :vat_from
  # t.datetime :vat_to
  # t.string   :state
  # t.datetime :calculated_at
  # t.datetime :reported_at
  # t.datetime :deadline
  # t.integer  :organization_id
  # t.integer  :accounting_period_id

  # t.timestamps

  #attr_accessible :name, :vat_from, :vat_to, :accounting_period_id, :deadline

  belongs_to :organization
  belongs_to :accounting_period
  has_many   :reversed_vat_reports, dependent: :destroy

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :vat_from, presence: true
  validates :vat_to, presence: true
  validate :check_to
  validate :overlaping_period
  validates :deadline, presence: true
  VALID_JOBS = %w(reversed_vat_report_job)

  def check_to
    if vat_from >= vat_to
      errors.add(:vat_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = ReversedVat
            .where('organization_id = ? and vat_to >= ? and vat_from <= ?' ,
                   organization_id, vat_from, vat_to).count
    if new_record?
      errors.add(:vat_to, I18n.t(:within_period)) if p > 0
    else
      errors.add(:vat_to, I18n.t(:within_period)) if p > 1
    end
  end

  STATE_CHANGES = [:mark_calculated, :mark_reported, :finnish_calculation]

  def state_change(event, changed_at = nil, user_id = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at, user_id)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_calculated, do: :calculate
    after_transition on: :mark_calculated, do: :enqueue_reversed_vat_report
    before_transition on: :mark_reported, do: :report

    event :mark_calculated do
      transition [:preliminary, :calculated] => :start_calculation
    end
    event :finnish_calculation do
      transition start_calculation: :calculated
    end
    event :mark_reported do
      transition calculated: :reported
    end
  end

  def calculate(transition)
    self.calculated_at = transition.args[0]
  end

  def report(transition)
    self.reported_at = transition.args[0]
  end

  def enqueue_reversed_vat_report
    logger.info '** ReversedVat enqueue a job that will create report.'
    ReversedVatJob.perform_later(id, 'reversed_vat_report_job')
  end

  # Run from the 'ReversedVatJob' model
  def reversed_vat_report_job
    logger.info '** ReversedVat reversed_vat_report_job start'
    reversed_vat_report_creator = Services::ReversedVatReportCreator.new(self)
    reversed_vat_report_creator.delete_reversed_vat_report
    if reversed_vat_report_creator.report
      logger.info "** ReversedVat #{id} reversed_vat_report returned ok, marking complete"
      finnish_calculation
    else
      logger.info "** ReversedVat #{id} reversed_vat_report did NOT return ok, not marking complete"
    end
  end

  def can_calculate?
    return false if state == 'reported'
    true
  end

  def can_report?
    return true if state == 'calculated'
    false
  end

  def calculated?
    ['calculated', 'reported'].include? state
  end

  def reported?
    return true if state == 'reported'
    false
  end

  def can_delete?
    return false if reported?
    return false if accounting_period.active
    true
  end
end
