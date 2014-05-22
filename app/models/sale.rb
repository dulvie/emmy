class Sale < ActiveRecord::Base
  # t.integer :user_id
  # t.integer :customer_id
  # t.integer :warehouse_id
  # t.string :contact_email
  # t.string :contact_name
  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :approved_at
  # t.timestamp :goods_delivered_at
  # t.timestamp :paid_at
  # t.datetime :due_date

  belongs_to :user
  belongs_to :customer
  belongs_to :warehouse
  has_many :sale_items

  attr_accessible :customer_id, :warehouse_id, :approved_at

  validates :customer_id, presence: true
  validates :warehouse_id, presence: true

  STATE_CHANGES = [
    :mark_item_complete, :start_processing, :mark_complete, # Generic state
    :deliver_goods, # Goods
    :pay,           # Money
  ]

  state_machine :state, initial: :meta_complete do

    event :mark_item_complete do
      transition :meta_complete => :item_complete
    end

    event :start_processing do
      transition :item_complete => :processing
    end

    event :mark_complete do
      transition :processing => :completed
    end
  end

  state_machine :goods_state, initial: :not_delivered do
    event :deliver_goods do
      transition :not_delivered => :delivered
    end
  end

  state_machine :money_state, initial: :not_paid do
    event :pay do
      transition :not_paid => :paid
    end
  end

  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['processing','completed'].include? state
    true
  end

  def is_completed?
    state.eql? 'completed'
  end

  def is_delivered?
    goods_state.eql? 'delivered'
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
    when 'meta_complete'
      :mark_item_complete
    when 'item_complete'
      :start_processing
    when 'processing'
      :mark_complete
    else
      raise RuntimeError, "Unknown state#{state} of sale#{self.id}"
    end
  end

end
