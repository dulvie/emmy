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

  after_initialize :defaults, unless: :persisted?

  def can_delete?
    purchase.can_edit_items?
  end

  private

  def defaults
    self.quantity ||= 0
    self.price ||= 0
    self.total_amount ||= 0
  end

end
