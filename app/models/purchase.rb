class Purchase < ActiveRecord::Base

  # t.integer :parent_id
  # t.string :parent_type  
  # t.integer :user_id
  # t.integer :supplier_id
  # t.string :contact_email
  # t.string :contact_name
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id
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

  belongs_to :user
  belongs_to :supplier
  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :parent, polymorphic: true
  has_many :purchase_items

  accepts_nested_attributes_for :purchase_items
  attr_accessible :description, :supplier_id, :contact_name, :contact_email, :our_reference_id, 
  :to_warehouse_id, :total_amount, :vat_amount, :ordered_at, :import_id, :parent_type, :parent_id

  validates :description, presence: true
  validates :supplier_id, presence: true

  VALID_PARENT_TYPES = ['Purchase', 'Production', 'Import']

  STATE_CHANGES = [
    :mark_item_complete, :mark_complete, # Generic state
    :receive,  # Goods
    :pay,      # Money
  ]

  state_machine :state, initial: :meta_complete do

    event :mark_item_complete do
      transition :meta_complete => :item_complete
    end

    event :mark_complete do
      transition :item_complete => :completed
    end
  end

  state_machine :goods_state, initial: :not_received do
    after_transition :not_received => :received, do: :check_for_completeness
    event :receive do
      transition :not_received => :received
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
    return false if  ['Production','Import'].include? self.parent_type
    return false if ['item_complete','completed'].include? state
    true
  end

  def is_ordered?
    state.eql? 'item_complete'
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

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)

    if self.send("#{new_state}")
      # Set state_change date.
      # Since the date for the action might be another than 'now'
      # and state changes doesn't take params, this needs to be done here.
      # It would be much nicer to do this in a state_machine after_transition hook.
      case new_state
      when 'mark_item_complete'
        self.ordered_at = changed_at
        return self.save
      when 'receive'
        self.received_at = changed_at
        return self.save
      when 'pay'
        self.paid_at = changed_at
        return self.save
      when 'mark_complete'
        self.completed_at = changed_at
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
      raise RuntimeError, "Unknown state#{state} of purchase#{self.id}"
    end
  end

  # after_transition filter for money_state and goods_state.
  def check_for_completeness
    if is_paid? and is_received?
      self.completed_at = Time.now
      self.mark_complete
    end
  end
  
  def items_total
    self.purchase_items.sum(:total_amount)
  end

end
