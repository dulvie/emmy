class ShelfSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :warehouse_id
  attributes :name, :batch_id, :in_price, :distributor_price, :retail_price, :vat
end
