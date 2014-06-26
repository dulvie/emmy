class Purchase < ActiveRecord::Base

  # t.integer :parent_id
  # t.string :parent_type

  # t.integer :user_id
  # t.integer :supplier_id
  # t.string :contact_email
  # t.string :contact_name
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id
  # t.integer :total_amount
  # t.integer :vat_amount

  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :ordered_at
  # t.timestamp :completed_at
  # t.timestamp :received_at
  # t.timestamp :paid_at
  # t.datetime :due_date

  belongs_to :user
  belongs_to :supplier
  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :parent, polymorphic: true
  has_many :purchase_items
  has_many :to_transaction, class_name: 'ProductTransaction', as: :parent

  accepts_nested_attributes_for :purchase_items
  attr_accessible :description, :supplier_id, :contact_name, :contact_email, :our_reference_id, 
  :to_warehouse_id, :total_amount, :vat_amount, :ordered_at, :parent_type, :parent_id

  validates :description, presence: true
  validates :supplier_id, presence: true

  VALID_PARENT_TYPES = ['Purchase', 'Production', 'Import']


  EVENTS = [
    :mark_item_complete, :mark_complete, # Generic state
    :receive,   # Goods
    :pay,       # Money
    ]

  def state_change(event, changed_at = nil)
   return false unless EVENTS.include?(event.to_sym)
   self.send(event, changed_at)
  end

  def next_event
    case state
    when 'meta_complete'
      :mark_item_complete
    when 'item_complete' || 'completed'
      nil 
    else
      raise RuntimeError, "Unknown state#{state} of purchase#{self.id}"
    end
  end


  state_machine :state, initial: :meta_complete do

    event :mark_item_complete do
      transition :meta_complete => :item_complete
    end
    before_transition :meta_complete => :item_complete, do:  :set_ordered

    event :mark_complete do
      transition :item_complete => :completed
    end
    before_transition :item_complete => :completed, do:  :set_completed
  end
  
  def set_ordered(transition)
    self.ordered_at = transition.args[0]
  end

  def set_completed(transition)
    self.completed_at = transition.args[0]
  end


  state_machine :goods_state, initial: :not_received do
    before_transition :not_received => :received, do:  :set_received
    after_transition :not_received => :received, do: :create_to_transactions
    after_transition :not_received => :received, do: :check_for_completeness
    event :receive do
      transition :not_received => :received
    end
  end

  def set_received(transition)
    self.received_at = transition.args[0]
  end

  def create_to_transactions
    purchase_items.each do |purchase_item|
      if purchase_item.item.stocked == true
        product_transaction = ProductTransaction.new(
          parent: self,
          warehouse: to_warehouse, 
          product: purchase_item.product, 
          quantity: purchase_item.quantity)
        product_transaction.save
      end
    end
  end


  state_machine :money_state, initial: :not_paid do
    before_transition :not_paid => :paid, do:  :set_paid
    after_transition :not_paid => :paid, do: :check_for_completeness
    event :pay do
      transition :not_paid => :paid
    end
  end

  def set_paid(transition)
    self.paid_at = transition.args[0]
  end


  # after_transition filter for money_state and goods_state.
  def check_for_completeness
    if is_paid? and is_received?
      self.mark_complete(Time.now)
    end
  end
 
 
  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if  ['Production','Import'].include? self.parent_type
    return false if ['item_complete','completed'].include? state
    true
  end

  def is_ordered?
    state.eql? 'item_complete'
  end
  
  def is_completed?
    state.eql? 'completed'
  end

  def is_received?
    goods_state.eql? 'received'
  end

  def is_paid?
    money_state.eql? 'paid'
  end

  def items_total
    self.purchase_items.sum(:total_amount)
  end

end
