class ShelfDecorator < Draper::Decorator
  delegate_all

  # Delegate the attributes from the batch as well.
  delegate :name, :in_price, :distributor_price, :retail_price, :vat, :unit
end
