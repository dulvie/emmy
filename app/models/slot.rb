class Slot < ActiveRecord::Base
  # t.integer :warehouse_id
  # t.integer :product_id
  # t.integer :quantity
  # t.integer :comment

  belongs_to :warehouse
  belongs_to :product
  has_many :slot_changes

  validates :warehouse_id, presence: true
  validates :product_id, presence: true

  # @todo This should have a validation to disable an update of the product_id and warehouse_id field
end
