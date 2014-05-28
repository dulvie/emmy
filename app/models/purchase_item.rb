class PurchaseItem < ActiveRecord::Base

  #t.integer :purchase_id
  #t.integer :product_id
  #t.integer :quantity
  #t.integer :price
  #t.integer :price_sum

  belongs_to :purchase
  belongs_to :product

  attr_accessible :product_id, :quantity, :price

  before_validation :calculate
  
  validates :product_id, presence: true
  validates :quantity, presence: true

  def can_delete?
    purchase.can_edit_items?
  end

  private

  # Callback: before_validation
  def calculate
    if quantity
      self.price_sum = price * quantity
    end
  end
end
