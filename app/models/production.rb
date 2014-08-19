class Production < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :user_id
  # t.string :description
  # t.integer :our_reference_id
  # t.integer :warehouse_id
  # t.integer :batch_id
  # t.integer :quantity
  # t.integer :cost_price
  # t.integer :total_amount

  # t.string :state
  # t.timestamp :started_at
  # t.timestamp :completed_at

  belongs_to :organisation
  belongs_to :our_reference, class_name: 'User'
  belongs_to :warehouse
  belongs_to :batch

  has_many :comments, as: :parent, :dependent => :destroy
  has_many :materials, :dependent => :destroy
  has_one :work, as: :parent, class_name: 'Purchase'
  has_one :from_transaction, class_name: 'BatchTransaction', as: :parent

  accepts_nested_attributes_for :materials, :work, :batch

  attr_accessible :description, :our_reference_id, :warehouse_id, :batch_id, :quantity, :cost_price,
                  :started_at, :completed_at, :organisation

  validates :description, presence: true
  validates :warehouse_id, presence: true

  def state_change(event, changed_at = nil)
   return false unless EVENTS.include?(event.to_sym)
   self.send(event, changed_at)
  end

  EVENTS = [:start, :complete]
  def next_event
    case state
    when 'not_started'
      :start
    when 'started'
      :complete
    else
      raise RuntimeError, "Unknown state#{state} of production#{self.id}"
    end
  end

  state_machine :state, initial: :not_started do

    event :start do
      transition :not_started => :started
    end
    before_transition on: :start, do:  :set_started
    after_transition on: :start, do: :create_from_transaction

    event :complete do
      transition :started => :completed
    end
    before_transition on: :complete, do:  :set_completed_and_calculate
    after_transition on: :complete, do: :create_to_transaction

  end

  def set_started(transition)
    self.started_at = transition.args[0]
    if self.work.state == 'meta_complete'
      self.work.state_change('mark_item_complete', self.started_at)
    end
  end

  def set_completed_and_calculate(transition)
    self.completed_at = transition.args[0]
    if self.work.goods_state == 'not_received'
      self.work.state_change('receive', self.completed_at)
    end
    material_amount = materials.first.batch.in_price * materials.first.quantity
    self.total_amount = work.total_amount + material_amount
    self.cost_price = self.total_amount / self.quantity
  end

  def create_from_transaction
    batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: materials.first.batch,
          quantity: materials.first.quantity * -1,
          organisation_id: self.organisation_id)
    batch_transaction.save
  end

  def create_to_transaction
    batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: batch,
          quantity: quantity,
          organisation_id: self.organisation_id)
    batch_transaction.save
  end


  def can_edit?
    state.eql? 'not_started'
  end

  def can_edit_state?
     return false if state.eql? 'completed'
     return false if self.batch_id.nil?
     return false if self.quantity.nil?
     return false if self.materials.size == 0
     return false if self.work.nil?
     return true
  end

  def can_delete?
    return false if ['started', 'completed'].include? state
    true
  end

  def is_started?
    state.eql? 'started'
  end

  def can_complete?
     return self.work.is_paid?
  end

  def is_completed?
    state.eql? 'completed'
  end

  def parent_name
    description
  end

end
