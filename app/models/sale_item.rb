class SaleItem < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :sale_id
  # t.integer :item_id
  # t.integer :batch_id
  # t.integer :quantity
  # t.integer :price
  # t.integer :price_inc_vat
  # t.integer :price_sum
  # t.integer :vat

  belongs_to :organisation
  belongs_to :sale
  belongs_to :item
  belongs_to :batch

  attr_accessible :item_id, :batch_id, :quantity, :price, :vat, :organisation

  before_validation :collect_and_calculate

  validates :item_id, presence: true
  validates :quantity, presence: true
  validates :price_inc_vat, presence: true
  validates :price_sum, presence: true
  validates :vat, presence: true

  def can_delete?
    sale.can_edit_items?
  end

  def total_vat
    self.quantity * (self.price_inc_vat - self.price)
  end

  private

  # Callback: before_validation
  def collect_and_calculate
    self.vat = self.vat || default_vat_from_batch
    self.price = self.price || default_from_batch(:price)
    self.price_inc_vat = price * (1 + (vat / 100.0))
    if quantity
      self.price_sum = price_inc_vat * quantity
    end
  end

  def default_vat_from_batch
    if batch
      if v = batch.vat.vat_percent
        return v
      end
    end
    return 0
  end

  def default_from_batch field
    if batch
      if v = batch.send(field)
        return v
      end
    end
    return 0
  end

end
