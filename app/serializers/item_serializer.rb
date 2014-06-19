class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :stocked
  has_many :products, key: :products
end
