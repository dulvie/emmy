class Transaction < ActiveRecord::Base
  # t.string :parent_type
  # t.integer :parent_id
  # t.integer :product_id
  # t.integer, :warehouse_id
  # t.integer :quantity

  belongs_to :product
  belongs_to :warehouse
  belongs_to :parent, polymorphic: true

  attr_accessible :warehouse, :warehouse_id, :product, :product_id, :parent_id, :parent, :quantity

  validates :warehouse, presence: true
  validates :product, presence: true
  validates :quantity, presence: true


  # @todo Not sure about this, doesn't feel 100% ok.
  def recalculate_shelf
    @shelf ||= warehouse.shelves.where(product_id: product_id).first
    @shelf.recalculate
  end

end
