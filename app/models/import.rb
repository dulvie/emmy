class Import < ActiveRecord::Base

  # t.integer :user_id
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id
  
  # t.string :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  has_many :costitems, as: :parent
  has_many :comments, as: :parent

  attr_accessible :description, :our_reference_id, :to_warehouse_id, :started_at, :completed_at

  validates :description, presence: true
  validates :to_warehouse_id, presence: true
  
  STATE_CHANGES = [
    :started, :complete, # Generic state
  ]

  state_machine :state, initial: :not_started do

    event :started do
      transition :not_started => :started
    end

    event :complete do
      transition :started => :complete
    end
  end

  def can_edit_items?
    state.eql? 'complete'
  end

  def can_delete?
    return true if ['not_started', 'started'].include? state
    false
  end

  def is_ordered?
    state.eql? 'started'
  end
  
  def is_completed?
    state.eql? 'complete'
  end

  def state_change(new_state)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    self.send("#{new_state}")
  end

  def next_step
    case state
    when 'not_started'
      :started
    when 'started'
      :complete
    else
      raise RuntimeError, "Unknown state#{state} of purchase#{self.id}"
    end
  end

  def items_total
    self.costitems.sum(:price_sum)
  end
end
