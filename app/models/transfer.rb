class Transfer < ActiveRecord::Base
  # t.integer :from_warehouse_id
  # t.integer :to_warehouse_id
  # t.integer :product_id
  # t.integer :quantity
  # t.integer :user_id
  # t.string  :state


  has_one :from_transaction, class_name: 'Transaction', as: :parent
  has_one :to_transaction, class_name: 'Transaction', as: :parent
  belongs_to :from_warehouse, class_name: 'Warehouse'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :product
  belongs_to :user
  has_many :comments, as: :parent

  attr_accessible :from_warehouse_id, :to_warehouse_id, :product_id, :quantity

  STATES=['not_sent', 'sent', 'received']

  validates :state, inclusion: STATES
  validates :from_warehouse, presence: true
  validates :to_warehouse, presence: true
  validates :product, presence: true
  validates :quantity, presence: true


  # State changes go through not_sent -> sent -> received
  state_machine :state, initial: :not_sent do


    event :send_package do
      transition not_sent: :sent
    end
    after_transition on: :send_package, do: :create_from_transaction

    event :receive_package do
      transition sent: :received
    end
    after_transition on: :receive_package, do: :create_to_transaction

  end


  def create_from_transaction
    t = build_from_transaction(
      warehouse_id: from_warehouse_id,
      product_id: product_id,
      quantity: quantity * -1 # the from transaction subtracts the quantity
    )
    t.save!
  end

  def create_to_transaction
    t = build_to_transaction(
      warehouse_id: to_warehouse_id,
      product_id: product_id,
      quantity: quantity
    )
    t.save!
  end

end
