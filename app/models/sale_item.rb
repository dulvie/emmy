class SaleItem < ActiveRecord::Base
  #t.integer :sale_id
  #t.integer :product_id
  #t.integer :quantity
  #t.integer :price
  #t.integer :price_inc_vat
  #t.integer :price_sum
  #t.integer :vat

  belongs_to :sale
  belongs_to :product

  attr_accessible :product_id, :quantity, :price

  before_validation :collect_and_calculate

  def can_delete?
    sale.can_edit_items?
  end

  private

  # before_validation
  def collect_and_calculate
    self.vat = product.vat unless vat
    self.price_inc_vat = price * (1 + vat / 100.0)
    self.price_sum = price_inc_vat * quantity
  end

end
