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
  validates :batch, presence: true, if: :item_stocked?
  validates :quantity, presence: true
  validates :price, presence: true

  # Callbacks
  after_validation :collect_and_calculate
  
  def item_stocked?
    item.stocked
  end

  def can_delete?
    purchase.can_edit_items?
  end

  def vat_amount
    price * quantity * vat / 100
  end

  private

  # Callback: after_validation
  def collect_and_calculate
    self.vat = vat || item.vat.vat_percent
    if quantity && price
      self.amount = quantity * price + vat_amount
    else
      self.amount = 0
    end
  end
end
