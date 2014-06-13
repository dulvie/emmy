class Production < ActiveRecord::Base

  # t.integer :user_id
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :warehouse_id
  # t.integer :product_id
  # t.integer :quantity
  # t.integer :cost_price
  # t.integer :total_amount

  # t.string :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :our_reference, class_name: 'User'
  belongs_to :warehouse
  belongs_to :product
  
  has_many :comments, as: :parent, :dependent => :destroy
  has_many :materials, :dependent => :destroy
  has_one :work, as: :parent, class_name: 'Purchase', :dependent => :destroy
  
  accepts_nested_attributes_for :materials, :work

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

  def can_edit?
    state.eql? 'not_started'
  end

  def can_edit_state?
     return false if state.eql? 'complete'
     return false if self.product_id.nil? 
     return false if self.quantity.nil?
     return false if self.materials.size == 0
     return false if self.work.nil?
     return true
  end
  
  def can_delete?
    return false if ['started', 'complete'].include? state
    true
  end

  def is_started?
    state.eql? 'started'
  end

  def is_completed?
    state.eql? 'complete'
  end

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)

    if self.send("#{new_state}")
      # Set state_change date if started or complete.
      case new_state
      when 'started'
        self.started_at = changed_at || Time.now
        self.work.state_change('mark_item_complete', changed_at)
        return self.save
      when 'complete'
        self.completed_at = changed_at || Time.now
        self.work.state_change('receive', changed_at)
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
      :started
    when 'started'
      :complete
    else
      raise RuntimeError, "Unknown state#{state} of production#{self.id}"
    end
  end

  private

end
