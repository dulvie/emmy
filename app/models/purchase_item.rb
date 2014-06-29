class PurchaseItem < ActiveRecord::Base

  #t.integer :purchase_id
  #t.integer :item_id
  #t.integer :product_id

  #t.integer :quantity
  #t.integer :price
  #t.integer :total_amount

  belongs_to :purchase
  belongs_to :item
  belongs_to :product

  attr_accessible :product_id, :item_id, :quantity, :price, :total_amount
  accepts_nested_attributes_for :item, :product

  validates :item_id, presence: true
  validates :quantity, presence: true
  validates :price, presence: true

  after_initialize :defaults, unless: :persisted?
  after_validation :calculate_amount

  def can_delete?
    purchase.can_edit_items?
  end

  private

  def defaults
  end

  def calculate_amount
    if self.quantity && self.price
      self.total_amount = self.quantity * self.price
    else
      self.total_amount = 0
    end
  end

end
