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

  attr_accessible :customer_id, :warehouse_id, :approved_at, :contact_email, :contact_name

  validates :customer_id, presence: true
  validates :warehouse_id, presence: true

  STATE_CHANGES = [
    :mark_item_complete, :mark_complete, # Generic state
    :deliver, # Goods
    :pay,     # Money
  ]

  state_machine :state, initial: :meta_complete do

    event :mark_item_complete do
      transition :meta_complete => :item_complete
    end

    event :mark_complete do
      transition :item_complete => :completed
    end
  end

  state_machine :goods_state, initial: :not_delivered do
    after_transition :not_delivered => :delivered, do: :check_for_completeness

    event :deliver do
      transition :not_delivered => :delivered
    end
  end

  state_machine :money_state, initial: :not_paid do
    after_transition :not_paid => :paid, do: :check_for_completeness
    event :pay do
      transition :not_paid => :paid
    end
  end

  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['completed','item_complete'].include? state
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

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)

    if self.send("#{new_state}")
      # Set state_change date.
      # Since the date for the action might be another than 'now'
      # and state changes doesn't take params, this needs to be done here.
      # It would be much nicer to do this in a state_machine after_transition hook.
      case new_state
      when 'deliver'
        self.delivered_at = changed_at || Time.now
        return self.save
      when 'pay'
        self.paid_at = changed_at || Time.now
        return self.save
      when 'mark_item_complete'
        self.approved_at = changed_at || Time.now
        return self.save
      end
      return true
    else
      return false
    end
  end

  def next_step
    case state
    when 'meta_complete'
      :mark_item_complete
    when 'item_complete' || 'completed'
      nil
    else
      raise RuntimeError, "Unknown state#{state} of sale#{self.id}"
    end
  end

  # after_transition filter for money_state and goods_state.
  def check_for_completeness
    if is_paid? and is_delivered?
      self.mark_complete
    end
  end

  # Summarize methods.

  # Not sure about the total_* methods, maybe they should go into the decorator...
  def total_price
    return 0 if sale_items.count <= 0
    sale_items.inject(0){|i, item| (item.price * item.quantity) + i}
  end

  def total_price_inc_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0){|i, item| item.price_sum + i}
  end

  def total_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0){|i, item| item.total_vat + i}
  end

end
