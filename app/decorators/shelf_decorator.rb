class ShelfDecorator < Draper::Decorator
  delegate_all

  # Delegate the attributes from the product as well.
  delegate :name, :product_type, :in_price, :distributor_price, :retail_price, :vat, :unit, :weight
end
