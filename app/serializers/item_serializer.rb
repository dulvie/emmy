class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :stocked, :unit, :in_price
  has_many :products, key: :products
end
