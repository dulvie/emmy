class TaxReturn < ActiveRecord::Base
  # t.string   :name
  # t.string   :tax_form
  # t.datetime :deadline
  # t.string   :state
  # t.datetime :calculated_at
  # t.datetime :reported_at
  # t.integer  :organization_id
  # t.integer  :accounting_period_id

  # t.timestamps

  attr_accessible :name, :tax_form, :deadline, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  has_many :tax_return_reports, dependent: :destroy

  VALID_TAX_FORMS = ['INK2 - Aktiebolag/ek.förening', 'INK3 - Ideell förening', 'INK4 - Handelsbolag', 'NE - Enskild firma']

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :deadline, presence: true
  validates :tax_form, inclusion: { in: VALID_TAX_FORMS }
  VALID_EVENTS = %w(tax_report_event)

  STATE_CHANGES = [:mark_calculated, :mark_reported]

  def state_change(event, changed_at = nil, user_id = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at, user_id)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_calulated, do: :calculate
    after_transition on: :mark_calculated, do: :generate_tax_agency_report
    before_transition on: :mark_reported, do: :report

    event :mark_calculated do
      transition preliminary: :start_calculation
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

  def generate_tax_agency_report(transition)
     # create_tax_agency_transaction('tax', self.deadline, transition.args[1])
     enqueue_tax_report
  end

  def report(transition)
    # här skapas verificate
    self.reported_at = transition.args[0]
  end

  def enqueue_tax_report
    logger.info '** TaxReturn enqueue a job that will create tax report.'
    Resque.enqueue(Job::TaxReturnEvent, id, 'tax_report_event')
  end

  # Run from the 'Job::TaxReturnEvent' model
  def tax_report_event
    logger.info '** TaxReturn tax_report_event start'
    vat_report_creator = Services::VatReportCreator.new(self)
    vat_report_creator.delete_vat_report

    tax_return_report_creator = Services::TaxReturnReportCreator.new(self)
    tax_return_report_creator.delete_report
    if tax_return_report_creator.report
      logger.info "** TaxReturn #{id} tax_report returned ok, marking complete"
      finnish_calculation
    else
      logger.info "** TaxReturn #{id} tax_report did NOT return ok, not marking complete"
    end
  end

  def create_tax_agency_transaction(report_type, post_date, user_id)
    tax_agency_transaction = TaxAgencyTransaction.new(
          parent: self,
          posting_date: post_date,
          user_id: user_id,
          report_type: report_type)
    tax_agency_transaction.organization_id = organization_id
    tax_agency_transaction.save
  end

  def can_calculate?
    return false if state == 'reported'
    true
  end

  def can_report?
    ['calculated', 'reported'].include? state
  end

  def calculated?
    return false if state == 'preliminary'
    true
  end

  def can_delete?
    return false if tax_return_reports.size > 0
    true
  end
end
