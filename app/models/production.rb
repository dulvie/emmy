class Production < ActiveRecord::Base
  # t.integer :organization_id
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

  scope :started, -> { where(state: 'started') }
  scope :completed, -> { where(state: 'completed') }

  belongs_to :organization
  belongs_to :our_reference, class_name: 'User'
  belongs_to :warehouse
  belongs_to :batch

  has_many :comments, as: :parent, dependent: :destroy
  has_many :materials,  dependent: :destroy
  has_one :work, as: :parent, class_name: 'Purchase', dependent: :destroy
  has_one :from_transaction, class_name: 'BatchTransaction', as: :parent

  accepts_nested_attributes_for :materials, :work, :batch
  delegate :unit, to: :batch

  #attr_accessible :description, :our_reference_id, :warehouse_id, :batch_id, :quantity, :cost_price,
  #                :started_at, :completed_at

  validates :description, presence: true
  validates :warehouse_id, presence: true

  EVENTS = [:start, :complete]

  def state_change(event, changed_at = nil)
    return false unless EVENTS.include?(event.to_sym)
    send(event, changed_at)
  end

  def next_event
    case state
    when 'not_started'
      :start
    when 'started'
      :complete
    else
      fail 'Unknown state#{state} of production#{id}'
    end
  end

  state_machine :state, initial: :not_started do

    event :start do
      transition not_started: :started
    end
    before_transition on: :start, do:  :start_production
    after_transition on: :start, do: :create_from_transaction

    event :complete do
      transition started: :completed
    end
    before_transition on: :complete, do:  :completed_and_calculate
    after_transition on: :complete, do: :create_to_transaction

  end

  def start_production(transition)
    self.started_at = transition.args[0]
    if work.state == 'meta_complete'
      work.state_change('mark_prepared', started_at)
    end
  end

  def completed_and_calculate(transition)
    self.completed_at = transition.args[0]
    if work.goods_state == 'not_received'
      work.state_change('receive', completed_at)
    end
    material_amount = materials.first.batch.in_price * materials.first.quantity
    self.total_amount = work.total_amount + material_amount
    total_cost_price = work.total_exkl_vat + material_amount
    self.cost_price = total_cost_price / quantity
  end

  def create_from_transaction
    batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: materials.first.batch,
          quantity: materials.first.quantity * -1)
    batch_transaction.organization_id = organization_id
    batch_transaction.save
  end

  def create_to_transaction
    batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: batch,
          quantity: quantity)
    batch_transaction.organization_id = organization_id
    batch_transaction.save
  end

  def can_edit?
    state.eql? 'not_started'
  end

  def can_delete?
    return false if ['started', 'completed'].include? state
    true
  end

  def started?
    state.eql? 'started'
  end

  def can_start?
    return false if ['started', 'completed'].include? state
    return false if state.eql? 'completed'
    return false if batch_id.nil?
    return false if quantity.nil?
    return false if materials.size == 0
    return false if work.nil?
    true
  end

  def can_complete?
    return false if !state.eql? 'started'
    work.paid?
  end

  def completed?
    state.eql? 'completed'
  end

  def parent_name
    description
  end

  def started?
    state.eql?('started')
  end


  def actions?
    return true if batch.nil?
    return true if can_start?
    return true if can_complete?
    return true if materials.size == 0
    return true if work.nil?
    return true if started? && !work.paid?
    false
  end

  def material?
    return true if materials.size > 0
    false
  end

  def work?
    return true if !work.nil?
    false
  end
end
