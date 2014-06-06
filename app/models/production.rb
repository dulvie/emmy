class Production < ActiveRecord::Base

  # t.integer :user_id
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :warehouse_id
  # t.integer :product_id
  # t.integer :quantity
  # t.integer :cost_price

  # t.string :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :our_reference, class_name: 'User'
  belongs_to :warehouse
  belongs_to :product
  
  has_many :comments, as: :parent
  has_many :materials
  has_many :costitems, as: :parent
  accepts_nested_attributes_for :costitems, :materials

  attr_accessible :description, :our_reference_id, :warehouse_id, :product_id, :quantity, :cost_price,
                  :started_at, :completed_at

  validates :description, presence: true
  validates :warehouse_id, presence: true
  
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
    state.eql? 'not_started'
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
      raise RuntimeError, "Unknown state#{state} of production#{self.id}"
    end
  end
 
  def costitems_size
    self.costitems.size
  end
  
  def materials_size
    self.materials.size
  end
     
  # For ApplicationHelper#delete_button
  def can_delete?; true; end
  
  private

end
