class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :stocked, :unit, :in_price, :distributor_price, :retail_price
  has_many :batches, key: :batches
end
