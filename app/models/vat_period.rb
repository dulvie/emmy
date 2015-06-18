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

  # t.timestamps


  attr_accessible :name, :vat_from, :vat_to, :accounting_period_id, :deadline

  belongs_to :organization
  belongs_to :accounting_period
  has_many :vat_reports
  has_one :verificate

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :vat_from, presence: true
  validates :vat_to, presence: true
  validate :check_to
  validate :overlaping_period
  validates :deadline, presence: true

  def check_to
    if vat_from >= vat_to
      errors.add(:vat_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = VatPeriod.where('organization_id = ? and vat_to >= ? and vat_from <= ?' , organization_id, vat_from, vat_to).count
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
    before_transition on: :mark_reported, do: :report
    after_transition on: :mark_reported, do: :generate_verificate_vat_report
    before_transition on: :mark_closed, do: :close

    event :mark_calculated do
      transition preliminary: :calculated
    end
    event :mark_reported do
      transition calculated: :reported
    end
    event :mark_closed do
      transition reported: :closed
    end
  end

  def calulate(transition)
    # här skapas momsunderlager
    self.calculated_at = transition.args[0]
  end

  def report(transition)
    # här skapas verificate
    self.reported_at = transition.args[0]
  end

  def generate_verificate_vat_report(transition)
     create_verificate_transaction('vat_report', self.deadline, transition.args[1])
  end

  def close(transition)
    self.closed_at = transition.args[0]
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
