class SlotChange < ActiveRecord::Base
  # t.integer :slot_id
  # t.integer :user_id
  # t.integer :quantity
  # t.string :change_type
  # t.string :current_state
  # t.integer :comments_count, :default => 0

  # Might add STATUS_IN_DELIVERY ...hmm...
  STATES = [STATE_DONE='done',
            STATE_IN_TRANSFER='in_transfer']

  TYPES = [TYPE_INVOICE='invoice',
           TYPE_LOSS='loss',
           TYPE_MANUAL='manual',
           TYPE_REFINEMENT='refinement',
           TYPE_TRANSFER='transfer']

  default_scope order("created_at DESC")
  belongs_to :slot
  belongs_to :user
  has_one :invoice_item
  has_many :comments, :counter_cache => true

  validates :slot_id, presence: true
  validates :user_id, presence: true

  validates :change_type, inclusion: { in: TYPES, message:"Invalid type"}
  validates :current_state, inclusion: { in: STATES, message: "Invalid state"}

  attr_accessible :quantity, :change_type, :slot_id

  # Sets the initial state based on the type.
  def initiate_state
    case change_type
    when TYPE_TRANSFER then
      self.current_state = STATE_IN_TRANSFER
    when TYPE_LOSS, TYPE_MANUAL, TYPE_INVOICE then
      self.current_state = STATE_DONE
    else
      # Default to empty, this will be catched by validation.
    end
  end
end
