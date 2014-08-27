class Transfer < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :from_warehouse_id
  # t.integer :to_warehouse_id
  # t.integer :batch_id
  # t.integer :quantity
  # t.integer :user_id

  # t.string  :state
  # t.timestamp :sent_at
  # t.timestamp :received_at


  has_one :from_transaction, class_name: 'BatchTransaction', as: :parent
  has_one :to_transaction, class_name: 'BatchTransaction', as: :parent

  belongs_to :from_warehouse, class_name: 'Warehouse'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :batch
  belongs_to :user
  belongs_to :organisation
  has_many :comments, as: :parent, :dependent => :destroy

  attr_accessible :from_warehouse_id, :to_warehouse_id, :batch_id, :quantity, :organisation_id
  accepts_nested_attributes_for :comments

  # Callbacks
  before_create :check_inventory

  STATES=['not_sent', 'sent', 'received']

  validates :state, inclusion: STATES
  validates :from_warehouse, presence: true
  validates :to_warehouse, presence: true
  validates :batch, presence: true
  validates :quantity, presence: true
  validates_exclusion_of :quantity, :in => 0..0, :message => "Positive or negative quantities"
  validates_associated :comments


  def name
    from_warehouse.name + ' => ' + to_warehouse.name
  end


  # State changes go through not_sent -> sent -> received
  state_machine :state, initial: :not_sent do

    event :send_package do
      transition not_sent: :sent
    end
    before_transition on: :send_package, do:  :set_sent
    after_transition on: :send_package, do: :create_from_transaction

    event :receive_package do
      transition sent: :received
    end
    before_transition on: :receive_package, do:  :set_received
    after_transition on: :receive_package, do: :create_to_transaction

  end

  # Callback: before_create
  def check_inventory
    if  Inventory.where('warehouse_id = ? AND state = ?', self.from_warehouse_id, 'started').count > 0
      self.errors.add(:from_warehouse, 'Inventory must complete before transfer')
      return false
    elsif Inventory.where('warehouse_id = ? AND state = ?', self.to_warehouse_id, 'started').count > 0
      self.errors.add(:to_warehouse, 'Inventory must complete before transfer')
      return false
    else
      return true
    end
  end

  def set_sent(transition)
    self.sent_at = transition.args[0]
  end

  def set_received(transition)
    self.received_at = transition.args[0]
  end

  def create_from_transaction
    t = build_from_transaction(
      warehouse_id: from_warehouse_id,
      batch_id: batch_id,
      quantity: quantity * -1, # the from_transaction subtracts the quantity
      organisation_id: organisation_id
    )
    t.save!
  end

  def create_to_transaction
    t = build_to_transaction(
      warehouse_id: to_warehouse_id,
      batch_id: batch_id,
      quantity: quantity,
      organisation_id: organisation_id
    )
    t.save!
  end

  def is_sent?
    ['sent','received'].include? state
  end

  def is_received?
    state.eql? 'received'
  end

  def can_delete?
     state.eql? 'not_sent'
  end

  def parent_name
    name
  end
end
