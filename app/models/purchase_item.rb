class PurchaseItem < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :purchase_id
  # t.integer :item_id
  # t.integer :batch_id

  # t.integer :quantity
  # t.integer :price
  # t.integer :amount
  # t.integer :vat

  belongs_to :organisation
  belongs_to :purchase
  belongs_to :item
  belongs_to :batch

  attr_accessible :batch_id, :item_id, :quantity, :price, :total_amount, :organisation, :organisation_id
  accepts_nested_attributes_for :item, :batch

  validates :item_id, presence: true
  validates :quantity, presence: true
  validates :price, presence: true

  # Callbacks
  after_validation :collect_and_calculate

  def can_delete?
    purchase.can_edit_items?
  end

  def vat_amount
    return self.price * self.quantity * self.vat / 100
  end


  private

  # Callback: after_validation
  def collect_and_calculate
    self.vat = self.vat || item.vat.vat_percent
    if self.quantity && self.price
      self.amount = self.quantity * self.price + vat_amount
    else
      self.amount = 0
    end
  end

end
