class ShelfSerializer < ActiveModel::Serializer
  attributes :id, :quantity
  attributes :name, :in_price, :distributor_price, :retail_price, :vat, :unit
end

