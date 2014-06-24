class Import < ActiveRecord::Base

  # t.integer :user_id
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id
  # t.integer :product_id
  # t.integer :quantity
  # t.integer :importing_id
  # t.integer :shipping_id
  # t.integer :customs_id 

  # t.string :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :product
  has_many :importing, as: :parent, class_name: 'Purchase', :dependent => :delete_all
  has_many :shipping, as: :parent, class_name: 'Purchase', :dependent => :delete_all
  has_many :customs, as: :parent, class_name: 'Purchase', :dependent => :delete_all
  has_many :comments, as: :parent, :dependent => :delete_all

  attr_accessible :description, :our_reference_id, :to_warehouse_id,  :product_id, :quantity,
    :importing_id, :shipping_id, :started_at, :completed_at

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

  def can_edit_state?
     return false if state.eql? 'complete'
     return false if self.importing_id.nil? 
     return false if self.shipping_id.nil?
     return false if self.customs_id.nil?
     return true
  end
  
  def can_edit_items?
    state.eql? 'not_started'
  end

  def can_delete?
    return false if ['started', 'complete'].include? state
    true
  end

  def is_ordered?
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
        self.started_at = changed_at
        return self.save
      when 'complete'
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
    when 'not_started'
      :started
    when 'started'
      :complete
    else
      raise RuntimeError, "Unknown state#{state} of purchase#{self.id}"
    end
  end

  def check_for_completeness
    if importing.first.is_completed? and shipping.first.is_completed? and customs.first.is_completed?
      self.completed_at = Time.now
      self.complete
      self.save
    end
  end

  def import_quantity
    self.importing.first.purchase_items.first.quantity
  end

end
