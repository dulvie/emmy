class ShelfSerializer < ActiveModel::Serializer
  attributes :id, :quantity
  attributes :name, :product_id, :in_price, :distributor_price, :retail_price, :vat, :unit
end

