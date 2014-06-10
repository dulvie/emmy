class Costitem < ActiveRecord::Base
  # t.string :parent_type
  # t.integer :parent_id

  # t.string :description
  # t.integer :supplier_id
  # t.string :contact_email
  # t.string :contact_name
  # t.integer :product_id
  # t.integer :quantity
  # t.integer :price
  # t.integer :total_amount
  # t.integer :vat_amount

  # t.string :state
  # t.string :goods_state
  # t.string :money_state

  # t.timestamp :ordered_at
  # t.timestamp :completed_at
  # t.timestamp :received_at
  # t.timestamp :paid_at
  # t.datetime :due_date

  belongs_to :parent, polymorphic: true
  belongs_to :supplier
  belongs_to :product

  attr_accessible  :description, :supplier_id, :contact_email, :contact_name, :product_id, :quantity, 
                   :price, :total_amount, :vat_amount, :ordered_at, :completed_at, :received_at,:paid_at, :due_date

  validates :description, presence: true
  validates :supplier_id, presence: true
  validates :product_id, presence: true
  validates :total_amount, presence: true
  validates :vat_amount, presence: true
    
  VALID_PARENT_TYPES = ['Import', 'Production', 'Transfer']

  STATE_CHANGES = [
    :start_processing, :end_processing, # Generic state
    :receive_goods,  # Goods
    :pay,            # Money
  ]
  def can_delete?
    return false if ['processing','completed'].include? state
    true
  end
  
  state_machine :state, initial: :not_started do

    event :start_processing do
      transition :not_started => :processing
    end

    event :end_processing do
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
 
  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)

    if self.send("#{new_state}")
      # Set state_change date if started or complete.
      case new_state
      when 'started'
        self.started_at = changed_at || Time.now
        return self.save
      when 'complete'
        self.completed_at = changed_at || Time.now
        return self.save
      when 'receive'
        self.received_at = changed_at || Time.now
        return self.save
      when 'pay'
        self.paid_at = changed_at || Time.now
        return self.save
      end
      return true
    else
      return false
    end
  end
  
  def next_step
    case state
    when 'not_started'
      :start_processing
    when 'end_processing'
      :completed
    when 'not_paid'
      :pay
    when 'not_received'
      :receive
    when 'end_processing'
      :completed
    else
      raise RuntimeError, "Unknown state#{state} of purchase#{self.id}"
    end
  end

  # For ApplicationHelper#delete_button
  def can_delete?; true; end

  def parent_name
    parent.description
  end
end
