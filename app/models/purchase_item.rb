class PurchaseItem < ActiveRecord::Base

  #t.integer :purchase_id
  #t.integer :item_id
  #t.integer :product_id

  #t.integer :quantity
  #t.integer :price
  #t.integer :amount
  #t.integer :vat

  belongs_to :purchase
  belongs_to :item
  belongs_to :product

  attr_accessible :product_id, :item_id, :quantity, :price, :total_amount
  accepts_nested_attributes_for :item, :product

  validates :item_id, presence: true
  validates :quantity, presence: true
  validates :price, presence: true

  after_initialize :defaults, unless: :persisted?
  after_validation :collect_and_calculate

  def can_delete?
    purchase.can_edit_items?
  end
  
  def vat_amount
    return self.price * self.quantity * self.vat / 100
  end


  private

  def collect_and_calculate
    self.vat = self.vat || item.vat
    if self.quantity && self.price
      self.amount = self.quantity * self.price + vat_amount
    else
      self.amount = 0
    end
  end

end
