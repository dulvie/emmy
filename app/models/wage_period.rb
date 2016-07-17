class WagePeriod < ActiveRecord::Base
  # t.string   :name
  # t.datetime :wage_from
  # t.datetime :wage_to
  # t.datetime :payment_date
  # t.datetime :deadline
  # t.string   :state
  # t.datetime :wage_calculated_at
  # t.datetime :wage_reported_at
  # t.datetime :wage_closed_at
  # t.datetime :tax_calculated_at
  # t.datetime :tax_reported_at
  # t.integer  :tax_closed_at
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :supplier_id

  # t.timestamps

  attr_accessible :name, :wage_from, :wage_to, :payment_date, :deadline, :accounting_period_id,
                  :supplier_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :supplier
  has_many :wages
  has_many :wage_reports, dependent: :destroy
  has_many :verificates

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :wage_from, presence: true
  validates :wage_to, presence: true
  validate :check_to
  validate :overlaping_period
  validates :payment_date, presence: true
  validates :deadline, presence: true
  VALID_EVENTS = %w(tax_report_event wage_calculation_event wage_verificate_event)

  def check_to
    if wage_from >= wage_to
      errors.add(:wage_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = WagePeriod
            .where('organization_id = ? and wage_to >= ? and wage_from <= ?',
                   organization_id, wage_from, wage_to)
            .count
    if new_record?
      errors.add(:wage_to, I18n.t(:within_period)) if p > 0
    else
      errors.add(:wage_to, I18n.t(:within_period)) if p > 1
    end
  end

  STATE_CHANGES = [:mark_wage_calculated, :mark_wage_reported, :mark_wage_closed,
                   :mark_tax_calculated, :mark_tax_reported, :mark_tax_closed]

  def state_change(event, changed_at = nil, user_id = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at, user_id)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_wage_calculated, do: :wage_calculate
    after_transition on: :mark_wage_calculated, do: :enqueue_wage_calculation
    before_transition on: :mark_wage_reported, do: :wage_report
    after_transition on: :mark_wage_reported, do: :enqueue_wage_verificate
    before_transition on: :mark_wage_closed, do: :wage_close
    before_transition on: :mark_tax_calculated, do: :tax_calculate
    after_transition on: :mark_tax_calculated, do: :enqueue_tax_report
    before_transition on: :mark_tax_reported, do: :tax_report
    after_transition on: :mark_tax_reported, do: :generate_verificate_tax
    before_transition on: :mark_tax_closed, do: :tax_close

    event :mark_wage_calculated do
      transition [:preliminary, :wage_calculated] => :start_wage_calculation
    end
    event :finnish_wage_calculation do
      transition start_wage_calculation: :wage_calculated
    end
    event :mark_wage_reported do
      transition wage_calculated: :wage_reported
    end
    event :mark_wage_closed do
      transition wage_reported: :wage_closed
    end
    event :mark_tax_calculated do
      transition wage_closed: :start_tax_calculation
    end
    event :finnish_tax_calculation do
      transition start_tax_calculation: :tax_calculated
    end
    event :mark_tax_reported do
      transition tax_calculated: :tax_reported
    end
    event :mark_tax_closed do
      transition tax_reported: :tax_closed
    end
  end

  def wage_calculate(transition)
    self.wage_calculated_at = transition.args[0]
  end

  def enqueue_wage_calculation
    logger.info '** WagePeriod enqueue a job that will create wages.'
    Resque.enqueue(Job::WagePeriodEvent, id, 'wage_calculation_event')
  end

  # Run from the 'Job::WagePeriodEvent' model
  def wage_calculation_event
    logger.info '** WagePeriod wage_calculation_event start'
    wage_creator = Services::WageCreator.new(self)
    wage_creator.delete_wages
    if wage_creator.save_wages
      logger.info "** WagePeriod #{id} wage_calculation returned ok, marking complete"
      finnish_wage_calculation
    else
      logger.info "** WagePeriod #{id} wage_calculation did NOT return ok, not marking complete"
    end
  end

  def wage_report(transition)
    self.wage_reported_at = transition.args[0]
  end

  def enqueue_wage_verificate(transition)
    logger.info '** WagePeriod enqueue a job that will create wage verificate.'
    Resque.enqueue(Job::WagePeriodEvent, id, 'wage_verificate_event')
  end

  # Run from the 'Job::WagePeriodEvent' model
  def wage_verificate_event
    logger.info '** WagePeriod create_verificate_event start'
    wage_verificate = Services::WageVerificate.new(self, payment_date)
    if wage_verificate.wage
      logger.info "** WagePeriod #{id} create_verificate returned ok"
    else
      logger.info "** WagePeriod #{id} create_verificate did NOT return ok"
    end
  end

  def generate_verificate_tax(transition)
    create_verificate_transaction('wage_tax', deadline, transition.args[1])
  end

  def wage_close(transition)
    self.wage_closed_at = transition.args[0]
  end

  def tax_calculate(transition)
    self.tax_calculated_at = transition.args[0]
  end

  def tax_report(transition)
    self.tax_reported_at = transition.args[0]
  end

  def tax_close(transition)
    self.tax_closed_at = transition.args[0]
  end

  def enqueue_tax_report
    logger.info '** WagePeriod enqueue a job that will create tax report.'
    Resque.enqueue(Job::WagePeriodEvent, id, 'tax_report_event')
  end

  # Run from the 'Job::WagePeriodEvent' model
  def tax_report_event
    logger.info '** WagePeriod tax_report_event start'
    wage_report_creator = Services::WageReportCreator.new(self)
    wage_report_creator.delete_wage_report
    if wage_report_creator.report
      logger.info "** WagePeriod #{id} tax_report returned ok, marking complete"
      finnish_tax_calculation
    else
      logger.info "** WagePeriod #{id} tax_report did NOT return ok, not marking complete"
    end
  end

  def create_verificate_transaction(ver_type, post_date, user_id)
    verificate_transaction = VerificateTransaction.new(
          parent: self,
          posting_date: post_date,
          user_id: user_id,
          verificate_type: ver_type)
    verificate_transaction.organization_id = organization_id
    verificate_transaction.save
  end

  def total_salary
    return 0 if wages.count <= 0
    wages.inject(0) { |i, item| item.salary + i }
  end

  def total_tax
    return 0 if wages.count <= 0
    wages.inject(0) { |i, item| item.tax + i }
  end

  def total_payroll_tax
    return 0 if wages.count <= 0
    wages.inject(0) { |i, item| item.payroll_tax + i }
  end

  def total_amount
    return 0 if wages.count <= 0
    wages.inject(0) { |i, item| item.amount + i }
  end

  def sum_tax
    total_tax + total_payroll_tax
  end

  def can_calculate_wage?
    ['preliminary', 'wage_calculated'].include? state
  end

  def can_calculate_tax?
    ['wage_closed', 'tax_calculated'].include? state
  end

  def can_report_wage?
    ['wage_calculated', 'wage_reported'].include? state
  end

  def can_report_tax?
    ['tax_calculated', 'tax_reported'].include? state
  end

  def show_wage?
    return false if state == 'preliminary'
    true
  end

  def show_tax?
    ['tax_calculated', 'tax_reported', 'tax_closed'].include? state
  end

  def can_delete?
    return false if wages.size > 0
    return false if wage_reports.size > 0
    true
  end
end
