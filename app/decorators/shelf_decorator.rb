class ShelfDecorator < Draper::Decorator
  delegate_all

  # Delegate the attributes from the product as well.
  delegate :name, :item_group, :in_price, :distributor_price, :retail_price, :vat, :unit
end
