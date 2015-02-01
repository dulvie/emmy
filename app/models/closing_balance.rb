class ClosingBalance < ActiveRecord::Base
  # t.datetime :posting_date
  # t.string   :description
  # t.string   :state
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.timestamps

  attr_accessible :description, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  has_many   :closing_balance_items, dependent: :delete_all

  validates :accounting_period_id, presence: true, uniqueness: {scope: [:organization_id, :accounting_period_id]}
  validates :description, presence: true

  STATE_CHANGES = [:mark_final]

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    send(new_state, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_final, do: :set_posting_date

    event :mark_final do
      transition preliminary: :final
    end
  end

  def set_posting_date(transition)
    self.posting_date = transition.args[0]
  end
  
  def total_debit
    return 0 if closing_balance_items.count <= 0
    closing_balance_items.inject(0) { |i, item| (item.debit || 0) + i }
  end

  def total_credit
    return 0 if closing_balance_items.count <= 0
    closing_balance_items.inject(0) { |i, item| (item.credit || 0) + i }
  end

  def can_delete?
    preliminary?
  end
end
