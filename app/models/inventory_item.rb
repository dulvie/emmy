class InventoryItem < ActiveRecord::Base

  #t.integer :inventory_id
  #t.integer :product_id

  #t.integer :shelf_quantity
  #t.integer :actual_quantity

  belongs_to :inventory
  belongs_to :product

  attr_accessible :inventory_id, :product_id, :shelf_quantity, :actual_quantity
  accepts_nested_attributes_for :product

  validates :product_id, presence: true
  validates :actual_quantity, presence: true

  def can_delete?
    inventory.can_edit_items?
  end
  

  private


end
