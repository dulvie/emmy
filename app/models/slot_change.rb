class SlotChange < ActiveRecord::Base
  # t.integer :slot_id
  # t.integer :user_id
  # t.integer :warehouse_id
  # t.integer :transfer_to_slot_id
  # t.integer :quantity, :default => 0
  # t.string :change_type
  # t.string :state
  # t.integer :comments_count, :default => 0

  # Might add a status such as STATUS_IN_DELIVERY ...hmm...
  STATES = [STATE_PENDING='pending',
            STATE_DONE='direct',
            STATE_PENDING='pending',
            STATE_DOING_TRANSFER='doing_transfer',
            STATE_AWAITING_TRANSFER='awaiting_transfer',
            STATE_FAILED_TRANSFER='failed_transfer',
            STATE_CONFIRMED_TRANSFER='confirmed_transfer']

  TYPES = [TYPE_INVOICE='invoice',
           TYPE_LOSS='loss',
           TYPE_MANUAL='manual',
           TYPE_REFINEMENT='refinement',
           TYPE_TRANSFER_OUT='transfer_out',
           TYPE_TRANSFER_IN='transfer_in']

  default_scope {order("created_at DESC")}
  belongs_to :slot
  belongs_to :user
  has_one :invoice_item
  has_many :comments, :counter_cache => true

  # The self join when doing a transfer
  belongs_to :transfer_to_slot, class_name: "SlotChange"
  has_one :transfer_from_slot,
    class_name: "SlotChange",
    foreign_key: "transfer_to_slot_id"

  #validates :slot_id, presence: true

  validates :change_type, inclusion: { in: TYPES, message:"Invalid type"}
  validates :state, inclusion: { in: STATES, message: "Invalid state"}

  attr_accessible :quantity, :change_type, :slot_id, :warehouse_id

  state_machine :initial => :pending do

    event :initiate_transfer do
      transition :pending => :doing_transfer
      transition any => :doing_transfer
    end

    event :initiate_receiving_transfer do
      transition :pending => :awaiting_transfer
    end

    event :initiate_direct do
      transition :pending => :direct
    end

    event :received_transfer do
      transition :awaiting_transfer => :confirmed_transfer
    end

    event :acknowledge_confirmed_transfer do
      transition :doing_transfer => :confirmed_transfer
    end

    event :invalidate_transfer do
      transition [:doing_transfer, :awaiting_transfer] => :failed_transfer
    end

    after_transition any => :failed_transfer do
      logger.info "failed transfer... fail"
    end

    before_transition :pending => :doing_transfer, :do => :create_receiving_slot_change
    before_transition :awaiting_transfer => :confirmed_transfer, :do => :say_thank_you

    state :doing_transfer do
      validates_presence_of :transfer_to_slot
    end

  end

  def is_out_transfer?
    self.change_type.eql? TYPE_TRANSFER_OUT
  end

  # @fixme doing this many save/updates might not scale very well...
  # is there a better pattern?
  def create_receiving_slot_change
    receiver = SlotChange.new_by_change_type :transfer_in, {}
    receiver.save
    receiver.initiate_receiving_transfer
    self.transfer_to_slot = receiver
    self.save
  end

  # Bad name. please come up with a better
  def say_thank_you
    from = transfer_from_slot
    from.acknowledge_confirmed_transfer
  end

  def self.new_by_change_type(type, params)
    new_change = new params
    new_change.change_type = type.to_s
    new_change
  end

end
