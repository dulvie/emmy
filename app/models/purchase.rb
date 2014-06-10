class Purchase < ActiveRecord::Base
  # t.integer :user_id
  # t.integer :supplier_id
  # t.string :contact_email
  # t.string :contact_name
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id
  # t.integer :sum
  # t.integer :vat_amount
  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :ordered_at
  # t.timestamp :completed_at
  # t.timestamp :goods_received_at
  # t.timestamp :paid_at
  # t.datetime :due_date
  
  belongs_to :user
  belongs_to :supplier
  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  has_many :purchase_items

  attr_accessible :description, :supplier_id, :contact_name, :contact_email, :our_reference_id, :to_warehouse_id, :ordered_at, :import_id

  validates :description, presence: true
  validates :supplier_id, presence: true

  STATE_CHANGES = [
    :start_processing, :order_complete, # Generic state
    :receive_goods,  # Goods
    :pay,            # Money
  ]

  state_machine :state, initial: :registration do

    event :start_processing do
      transition :registration => :processing
    end

    event :order_complete do
      transition :processing => :completed
    end
  end

  state_machine :goods_state, initial: :not_received do
    event :receive_goods do
      transition :not_received => :received
    end
  end

  state_machine :money_state, initial: :not_paid do
    event :pay do
      transition :not_paid => :paid
    end
  end

  def can_edit_items?
    state.eql? 'registration'
  end

  def can_delete?
    return false if ['processing','completed'].include? state
    true
  end

  def is_ordered?
    state.eql? 'processing'
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

  def state_change(new_state)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    self.send("#{new_state}")
  end

  def next_step
    case state
    when 'registration'
      :start_processing
    when 'processing'
      :order_complete
    else
      raise RuntimeError, "Unknown state#{state} of purchase#{self.id}"
    end
  end

  def items_total
    self.purchase_items.sum(:price_sum)
  end

end
