class SlotChange < ActiveRecord::Base
  # t.integer :slot_id
  # t.integer :user_id
  # t.integer :change_type
  # t.integer :current_state

  belongs_to :slot
  belongs_to :user
  has_one :invoice_item

  validates :slot_id, presence: true
  validates :user_id, presence: true
end
