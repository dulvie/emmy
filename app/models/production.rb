class Production < ActiveRecord::Base

  # t.integer :user_id
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :warehouse_id
  # t.integer :product_id
  # t.integer :quantity
  # t.integer :cost_price
  # t.integer :total_amount

  # t.string :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :our_reference, class_name: 'User'
  belongs_to :warehouse
  belongs_to :product

  has_many :comments, as: :parent, :dependent => :destroy
  has_many :materials, :dependent => :destroy
  has_one :work, as: :parent, class_name: 'Purchase'
  has_one :from_transaction, class_name: 'ProductTransaction', as: :parent
  
  accepts_nested_attributes_for :materials, :work, :product

  attr_accessible :description, :our_reference_id, :warehouse_id, :product_id, :quantity, :cost_price,
                  :started_at, :completed_at

  validates :description, presence: true
  validates :warehouse_id, presence: true

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
      raise RuntimeError, "Unknown state#{state} of production#{self.id}"
    end
  end

  state_machine :state, initial: :not_started do

    event :start do
      transition :not_started => :started
    end
    before_transition :not_started => :started, do:  :set_started
    after_transition :not_started => :started, do: :create_from_transaction

    event :complete do
      transition :started => :completed
    end
    before_transition :started => :completed, do:  :set_completed
    after_transition :started => :completed, do: :create_to_transaction

  end

  def set_started(transition)
    self.started_at = transition.args[0]
    self.work.state_change('mark_item_complete', self.started_at)
  end

  def set_completed(transition)
    self.completed_at = transition.args[0]
    self.work.state_change('receive', self.completed_at)
  end

  def create_from_transaction
    product_transaction = ProductTransaction.new(
          parent: self,
          warehouse: warehouse, 
          product: materials.first.product, 
          quantity: materials.first.quantity * -1)
    product_transaction.save
  end

  def create_to_transaction
    product_transaction = ProductTransaction.new(
          parent: self,
          warehouse: warehouse, 
          product: product, 
          quantity: quantity)
    product_transaction.save
  end


  def can_edit?
    state.eql? 'not_started'
  end

  def can_edit_state?
     return false if state.eql? 'completed'
     return false if self.product_id.nil? 
     return false if self.quantity.nil?
     return false if self.materials.size == 0
     return false if self.work.nil?
     return true
  end

  def can_delete?
    return false if ['started', 'completed'].include? state
    true
  end

  def is_started?
    state.eql? 'started'
  end

  def can_complete?
    return self.work.is_paid?
  end

  def is_completed?
    state.eql? 'completed'
  end

  def parent_name
    description
  end
  private

end