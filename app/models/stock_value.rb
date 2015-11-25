class StockValue < ActiveRecord::Base
  # t.string   :name
  # t.text     :comment
  # t.datetime :value_date
  # t.integer  :value
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :comment, :value_date, :value

  belongs_to :organization
  has_many   :stock_value_items, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: [:organization_id] }
  validates :value_date, presence: true

  STATE_CHANGES = [:mark_reported]

  def state_change(event, changed_at = nil, user_id = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at, user_id)
  end

  state_machine :state, initial: :preliminary do
    before_transition on:  :mark_reported, do: :report
    after_transition on:  :mark_reported, do: :generate_verificate_stock_value

    event :mark_reported do
      transition preliminary: :reported
    end
  end

  def report(transition)
    self.reported_at = transition.args[0]
  end

  def generate_verificate_stock_value(transition)
    create_verificate_transaction('stock_value', transition.args[0], transition.args[1])
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

  def can_edit?
    return false if self.reported?
    true
  end

  def can_delete?
    return false if self.reported?
    true
  end
end
