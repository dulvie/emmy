class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :stocked, :unit, :in_price
  has_many :batches, key: :batches
end
