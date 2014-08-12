class Import < ActiveRecord::Base

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

  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :batch
  has_many :importing, as: :parent, class_name: 'Purchase', :dependent => :delete_all
  has_many :shipping, as: :parent, class_name: 'Purchase', :dependent => :delete_all
  has_many :customs, as: :parent, class_name: 'Purchase', :dependent => :delete_all
  has_many :comments, as: :parent, :dependent => :delete_all

  attr_accessible :description, :our_reference_id, :to_warehouse_id,  :batch_id, :quantity,
    :importing_id, :shipping_id, :started_at, :completed_at

  validates :description, presence: true
  validates :to_warehouse_id, presence: true

  def state_change(event, changed_at = nil)
   return false unless EVENTS.include?(event.to_sym)
   self.send(event, changed_at)
  end

  EVENTS = [:start, :complete]

  def next_event
    case state
    when 'not_started'
      :start
    when 'started'
      :complete
    else
      raise RuntimeError, "Unknown state#{state} of purchase#{self.id}"
    end
  end

  state_machine :state, initial: :not_started do

    event :start do
      transition :not_started => :started
    end
    before_transition on: :start, do:  :set_started

    event :complete do
      transition :started => :completed
    end
    before_transition on: :complete, do:  :set_completed_and_calculate

  end

  def set_started(transition)
    self.started_at = transition.args[0]
  end

  def set_completed_and_calculate(transition)
    self.completed_at = transition.args[0]
    amount = Purchase.find(importing_id).total_amount + Purchase.find(shipping_id).total_amount + Purchase.find(customs_id).total_amount
    self.amount = amount
    self.cost_price = amount / self.import_quantity
  end

  def can_edit_state?
     return false if state.eql? 'completed'
     return false if self.importing_id.nil?
     return false if self.shipping_id.nil?
     return false if self.customs_id.nil?
     return true
  end

  def can_edit_items?
    state.eql? 'not_started'
  end

  def can_delete?
    return false if ['started', 'completed'].include? state
    true
  end

  def is_started?
    state.eql? 'started'
  end

  def is_completed?
    state.eql? 'completed'
  end

  def check_for_completeness
    if Purchase.find(importing_id).is_completed? && Purchase.find(shipping_id).is_completed? && Purchase.find(customs_id).is_completed?
      self.complete(Time.now)
    end
  end

  def import_quantity
    return 0 if self.importing.first.nil?
    self.importing.first.purchase_items.first.quantity
  end

  def parent_name
    description
  end

end
