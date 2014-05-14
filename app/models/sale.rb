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

  attr_accessible :customer_id

  state_machine :state, initial: :incomplete do
    event :mark_complete do
      transition :incomplete => :complete
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

  def is_updateable?
    state.eql? 'incomplete'
  end

end
