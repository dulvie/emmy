class Purchase < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :parent_id
  # t.string :parent_type

  # t.integer :user_id
  # t.integer :supplier_id
  # t.string :contact_email
  # t.string :contact_name
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id

  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :ordered_at
  # t.timestamp :completed_at
  # t.timestamp :received_at
  # t.timestamp :paid_at
  # t.datetime :due_date

  scope :prepared, -> { where(state: 'prepared') }
  scope :not_received, -> { where(goods_state: 'not_received') }

  belongs_to :organisation
  belongs_to :user
  belongs_to :supplier
  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :parent, polymorphic: true
  has_many :purchase_items, dependent: :delete_all
  has_many :documents, as: :parent, dependent: :delete_all
  has_many :to_transaction, class_name: 'BatchTransaction', as: :parent

  accepts_nested_attributes_for :purchase_items
  attr_accessible :description, :supplier_id, :contact_name, :contact_email, :our_reference_id,
                  :to_warehouse_id, :ordered_at, :parent_type, :parent_id, :organisation, :organisation_id

  validates :description, presence: true
  validates :supplier_id, presence: true

  VALID_PARENT_TYPES = ['Purchase', 'Production', 'Import']

  EVENTS = [
    :mark_prepared, :mark_complete, # Generic state
    :receive,   # Goods
    :pay,       # Money
  ]

  def state_change(event, changed_at = nil)
    return false unless EVENTS.include?(event.to_sym)
    send(event, changed_at)
  end

  def next_event
    case state
    when 'meta_complete'
      :mark_prepared
    when 'prepared' || 'completed'
      nil
    else
      fail 'Unknown state#{state} of purchase#{id}'
    end
  end

  state_machine :state, initial: :meta_complete do
    before_transition on: :mark_prepared, do: :prepare_purchase
    before_transition on: :mark_complete, do: :complete_purchase

    event :mark_prepared do
      transition meta_complete: :prepared
    end

    event :mark_complete do
      transition prepared: :completed
    end
  end

  def prepare_purchase(transition)
    self.ordered_at = transition.args[0]
  end

  def complete_purchase(transition)
    self.completed_at = transition.args[0]
  end

  state_machine :goods_state, initial: :not_received do
    before_transition on: :receive, do:  :receive_purchase
    after_transition on: :receive, do: :create_to_transactions
    after_transition on: :receive, do: :check_for_completeness

    event :receive do
      transition not_received: :received
    end
  end

  def receive_purchase(transition)
    self.received_at = transition.args[0]
  end

  def create_to_transactions
    purchase_items.each do |purchase_item|
      if purchase_item.item.stocked == true
        batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: to_warehouse,
          batch: purchase_item.batch,
          quantity: purchase_item.quantity,
          organisation_id: organisation_id)
        batch_transaction.save
      end
    end
  end

  state_machine :money_state, initial: :not_paid do
    before_transition on: :pay, do: :pay_purchase
    after_transition on: :pay, do: :check_for_completeness
    event :pay do
      transition not_paid: :paid
    end
  end

  def pay_purchase(transition)
    self.paid_at = transition.args[0]
  end

  # after_transition filter for money_state and goods_state.
  def check_for_completeness
    mark_complete(Time.now) if paid? && received?
  end

  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['Production', 'Import'].include? parent_type
    return false if ['prepared', 'completed'].include? state
    true
  end

  def prepared?
    state.eql? 'prepared'
  end

  def completed?
    state.eql? 'completed'
  end

  def received?
    goods_state.eql? 'received'
  end

  def paid?
    money_state.eql? 'paid'
  end

  def total_amount
    return 0 if purchase_items.count <= 0
    purchase_items.inject(0) { |i, item| item.amount + i }
  end

  def total_vat
    return 0 if purchase_items.count <= 0
    purchase_items.inject(0) { |i, item| item.vat_amount + i }
  end

  def parent_name
    description
  end
end
