class Inventory < ActiveRecord::Base

  # t.integer :user_id
  # t.integer :warehouse_id
  # t.datetime :inventory_date

  # t.string  :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :user
  belongs_to :warehouse
  has_many :inventory_items
  has_many :inventory_transactions, class_name: 'ProductTransaction', as: :parent

  accepts_nested_attributes_for :inventory_items
  attr_accessible :description, :user_id, :warehouse_id, :inventory_date

  before_create :check_transfer

  validates :warehouse, presence: true
  validates :inventory_date, presence: true

  EVENTS = [:start, :complete]

  def next_event
    case state
    when 'not_started'
      :start
    when 'started'
      :complete
    else
      raise RuntimeError, "Unknown state#{state} of inventory#{self.id}"
    end
  end

  def state_change(event, changed_at = nil)
   return false unless EVENTS.include?(event.to_sym)
   self.send(event, changed_at)
  end

  state_machine :state, initial: :not_started do

    before_transition on: :start, do: :set_started
    after_transition on: :start, do: :add_inventory_items

    before_transition on: :complete, do: :set_completed
    after_transition on: :complete, do: :create_inventory_transactions

    event :start do
      transition :not_started => :started
    end

    event :complete do
      transition :started => :completed
    end
  end

  def check_transfer
    if  Transfer.where('to_warehouse_id = ? AND state <> ?', self.warehouse_id, 'received').count > 0
      self.errors.add(:warehouse, 'Transfer to not received')
      return false
    elsif Transfer.where('from_warehouse_id = ? AND state <> ?', self.warehouse_id, 'received').count > 0
      self.errors.add(:warehouse, 'Transfer from not received')
      return false
    else
      return true
    end
  end

  def set_started(transition)
    self.started_at = transition.args[0]
  end

  def add_inventory_items
    self.warehouse.shelves.each do |shelf|
      @inventory_item = self.inventory_items.new(
        product_id: shelf.product_id,
        shelf_quantity: shelf.quantity,
        actual_quantity: shelf.quantity)
      @inventory_item.save
    end
  end

  def set_completed(transition)
    self.completed_at = transition.args[0]
  end

  def create_inventory_transactions
    inventory_items.each do |item|
      shelf = Shelf.where('warehouse_id' => self.warehouse_id, 'product_id' => item.product_id).first
      if item.actual_quantity != shelf.quantity
        product_transaction = ProductTransaction.new(
          parent: self,
          warehouse: warehouse, 
          product: item.product, 
          quantity: item.actual_quantity - shelf.quantity)
        product_transaction.save
      end
    end
  end


  def can_edit_items?
    state.eql? 'not_started'
  end

  def can_delete?
    state.eql? 'not_started'
  end

  def can_start?
    #kontrollera så inte det finns transfer sent men inte received
  end

  def is_started?
    state.eql? 'item_started'
  end
  
  def is_completed?
    state.eql? 'completed'
  end

end
