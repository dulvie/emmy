class Sale < ActiveRecord::Base
  # t.integer :user_id
  # t.integer :customer_id
  # t.integer :warehouse_id
  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :goods_delivered_at
  # t.timestamp :paid_at
  # t.datetime :due_date

  belongs_to :user
  belongs_to :customer
  belongs_to :warehouse
  has_many :sale_items

  attr_accessible :customer_id, :warehouse_id

  validates :customer_id, presence: true
  validates :warehouse_id, presence: true

  state_machine :state, initial: :new do
    event :mark_meta_complete do
      transition :new => :meta_complete
    end

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

  def can_update_base_info?
    state.eql? 'new'
  end

  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['processing','completed'].include? state
    true
  end

  def next_step
    case state
    when 'new'
      :mark_meta_complete
    when 'meta_complete'
      :mark_item_complete
    when 'item_complete'
      :start_processing
    when 'processing'
      :mark_complete
    else
      raise RuntimeError, "Unknown state of sale#{self.id}"
    end
  end

end
