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
  # Don't allow two slots for the same product
  validates :product_id, :uniqueness => {:scope => :warehouse_id}

  def self.new_by_associations prms
    me = Slot.new
    me.warehouse_id = prms[:warehouse_id]
    me.product_id = prms[:product_id]
    me
  end

  # @todo This should have a validation to disable an update of the product_id and warehouse_id field

  # Convinient helpers
  def product_name
    product.name
  end

  # @fixme Does this really scale?
  # Can this be refactord into something that scale betters?
  # To only do (old_value + change_value) instead of a full recalculation maybe?
  def recalculate_quantity_and_save
    self.quantity = slot_changes.sum(:quantity)
    save
  end
end
