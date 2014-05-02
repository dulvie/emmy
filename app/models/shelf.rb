class Shelf < ActiveRecord::Base
  # t.integer :quantity
  # t.integer :warehouse_id
  # t.integer :product_id

  belongs_to :warehouse
  belongs_to :product
  has_many :transactions, through: :warehouse

  attr_accessible :quantity, :product_id, :warehouse_id

  def recalculate 
    self.quantity = transactions.sum(:quantity)
    save!
  end
end
