class Inventory < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :user_id
  # t.integer :warehouse_id
  # t.datetime :inventory_date

  # t.string  :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :organization
  belongs_to :user
  belongs_to :warehouse
  has_many :inventory_items
  has_many :inventory_transactions, class_name: 'BatchTransaction', as: :parent
  has_many :comments, as: :parent

  accepts_nested_attributes_for :inventory_items
  attr_accessible :description, :user_id, :warehouse_id, :inventory_date, :organization

  # Callbacks
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
      fail "Unknown state#{state} of inventory#{id}"
    end
  end

  def state_change(event, changed_at = nil)
    return false unless EVENTS.include?(event.to_sym)
    send(event, changed_at)
  end

  state_machine :state, initial: :not_started do

    before_transition on: :start, do: :start_inventory
    after_transition on: :start, do: :add_inventory_items

    before_transition on: :complete, do: :complete_inventory
    after_transition on: :complete, do: :create_inventory_transactions

    event :start do
      transition not_started: :started
    end

    event :complete do
      transition started: :completed
    end
  end

  # Callback: before_create
  def check_transfer
    if  Transfer.where('to_warehouse_id = ? AND state <> ?', warehouse_id, 'received').count > 0
      errors.add(:warehouse, 'Transfer to not received')
      return false
    elsif Transfer.where('from_warehouse_id = ? AND state <> ?', warehouse_id, 'received').count > 0
      errors.add(:warehouse, 'Transfer from not received')
      return false
    else
      return true
    end
  end

  def start_inventory(transition)
    self.started_at = transition.args[0]
  end

  def add_inventory_items
    warehouse.shelves.each do |shelf|
      @inventory_item = inventory_items.new(
        batch_id: shelf.batch_id,
        shelf_quantity: shelf.quantity,
        actual_quantity: shelf.quantity,
        organization_id: shelf.organization_id,
        reported: false)
      @inventory_item.save
    end
  end

  def complete_inventory(transition)
    self.completed_at = transition.args[0]
  end

  def create_inventory_transactions
    inventory_items.each do |item|
      shelf = Shelf.where('warehouse_id' => warehouse_id, 'batch_id' => item.batch_id).first
      if item.actual_quantity != shelf.quantity
        batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: item.batch,
          quantity: item.actual_quantity - shelf.quantity,
          organization_id: item.organization_id)
        batch_transaction.save
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
    # kontrollera så inte det finns transfer sent men inte received
  end

  def started?
    state.eql? 'item_started'
  end

  def completed?
    state.eql? 'completed'
  end

  # Required by comments breadcrumb.
  def parent_name
    "##{id}"
  end
end
