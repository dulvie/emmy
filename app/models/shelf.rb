class Shelf < ActiveRecord::Base
  # t.integer :quantity
  # t.integer :warehouse_id
  # t.integer :product_id

  belongs_to :warehouse
  belongs_to :product

  attr_accessible :quantity, :product_id, :warehouse_id

  validates :product_id, presence: true
  validates :warehouse_id, presence: true

  delegate :name, :in_price, :distributor_price, :retail_price, :vat, :unit, :item_group, to: :product

  # Cache the product_transaction quantity sum of product in the warehouse.
  def recalculate
    self.quantity = ProductTransaction.where(warehouse_id: warehouse_id).where(product_id: product_id).sum(:quantity)
    save!
  end
end
