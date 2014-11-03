class Import < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :user_id
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id
  # t.integer :batch_id
  # t.integer :quantity
  # t.integer :amount
  # t.integer :cost_price
  # t.integer :importing_id
  # t.integer :shipping_id
  # t.integer :customs_id

  # t.string :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  # OBS! Användningen av importing/shipping/customs går fel då sökning sker från purchases parent id

  belongs_to :organization
  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :batch
  has_many :importing, as: :parent, class_name: 'Purchase', dependent: :delete_all
  has_many :shipping, as: :parent, class_name: 'Purchase', dependent: :delete_all
  has_many :customs, as: :parent, class_name: 'Purchase', dependent: :delete_all
  has_many :comments, as: :parent, dependent: :delete_all

  attr_accessible :description, :our_reference_id, :to_warehouse_id,  :batch_id, :quantity,
                  :importing_id, :shipping_id, :started_at, :completed_at

  validates :description, presence: true
  validates :to_warehouse_id, presence: true

  def state_change(event, changed_at = nil)
    return false unless EVENTS.include?(event.to_sym)
    send(event, changed_at)
  end

  EVENTS = [:start, :complete]

  def next_event
    case state
    when 'not_started'
      :start
    when 'started'
      :complete
    else
      fail "Unknown state#{state} of purchase#{id}"
    end
  end

  state_machine :state, initial: :not_started do
    before_transition on: :complete, do:  :completed_and_calculate

    event :start do
      transition not_started: :started
    end
    before_transition on: :start, do:  :start_import

    event :complete do
      transition started: :completed
    end
  end

  def start_import(transition)
    self.started_at = transition.args[0]
  end

  def purchases
    Purchase.where('id in (?)', [importing_id, shipping_id, customs_id])
  end

  def completed_and_calculate(transition)
    self.completed_at = transition.args[0]
    self.amount = purchases.inject(0) { |acc, p| acc += p.total_amount }
    self.cost_price = amount / import_quantity
  end

  def can_edit_state?
    return false if state.eql? 'completed'
    return false if importing_id.nil?
    return false if shipping_id.nil?
    return false if customs_id.nil?
    true
  end

  def can_edit_items?
    state.eql? 'not_started'
  end

  def can_delete?
    return false if ['started', 'completed'].include? state
    true
  end

  def started?
    state.eql? 'started'
  end

  def completed?
    state.eql? 'completed'
  end

  # Ensures the purchases are complete (import, shopping and customs).
  def check_for_completeness
    purch_states = purchases.pluck(:state)
    unique_states = purch_states.uniq
    return unless unique_states.size.eql? 1
    purchases_state = unique_states.first
    complete(Time.now) if purchases_state.eql? 'completed'
  end

  def import_quantity
    return 0 if importing.first.nil?
    importing.first.purchase_items.first.quantity
  end

  def import_price
    return 0 if importing.first.nil?
    importing.first.purchase_items.first.price
  end

  def parent_name
    description
  end
end
