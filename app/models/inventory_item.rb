class InventoryItem < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :inventory_id
  # t.integer :batch_id

  # t.integer :shelf_quantity
  # t.integer :actual_quantity

  belongs_to :organization
  belongs_to :inventory
  belongs_to :batch

  attr_accessible :inventory_id, :batch_id, :shelf_quantity, :actual_quantity, :reported
  accepts_nested_attributes_for :batch

  validates :batch_id, presence: true
  validates :actual_quantity, presence: true

  def can_delete?
    inventory.can_edit_items?
  end

end
