class SaleItem < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :sale_id
  # t.integer :item_id
  # t.integer :batch_id
  # t.string  :name
  # t.integer :quantity
  # t.integer :price
  # t.integer :price_inc_vat # NOT USED ANYMORE
  # t.integer :price_sum
  # t.integer :vat

  belongs_to :organization
  belongs_to :sale
  belongs_to :item
  belongs_to :batch

  attr_accessible :quantity, :price

  attr_accessor :row_type

  # Callbakcs
  before_validation :collect_and_calculate

  validates :quantity, presence: true
  validates :price_sum, presence: true
  validates :vat, presence: true
  validates :name, presence: true, if: :text_row?

  def price_with_vat
  end

  def text_row?
    return false if !self.item.nil?
    true
  end

  def can_delete?
    sale.can_edit_items?
  end

  def total_vat
    (quantity * price * (vat / 100.0))
  end

  def total_vat_25
    return (quantity * price * (vat / 100.0)) if vat == 25
    0.0
  end

  def total_vat_12
    return (quantity * price * (vat / 100.0)) if vat == 12
    0.0
  end

  def total_vat_06
    return (quantity * price * (vat / 100.0)) if vat == 6
    0.0
  end

  def product
  end

  def quantity_text
  end

  def desc
    return name if !name.nil? && name.length > 2
    return self.batch.name if !batch.nil?
    return item.name if !item.nil?
    'Name error'
  end

  private

  # Callback: before_validation
  def collect_and_calculate
    self.vat = vat || default_vat_from_batch
    self.price = price || default_from_batch(:price)
    self.quantity = 1 unless quantity
    self.price_sum = price * quantity
    self.price_inc_vat = (price_sum + total_vat)
  end

  def default_vat_from_batch
    if batch
      if v = batch.vat.vat_percent
        return v
      end
    elsif item
      if v = item.vat.vat_percent
        return v
      end
    end
    0
  end

  def default_from_batch(field)
    if batch
      if v = batch.send(field)
        return v
      end
    end
    0
  end
end
