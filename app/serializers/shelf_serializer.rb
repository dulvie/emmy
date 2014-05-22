class ShelfSerializer < ActiveModel::Serializer
  attributes :id, :quantity
  attributes :name, :product_type, :in_price, :distributor_price, :retail_price, :vat, :unit, :weight
end

