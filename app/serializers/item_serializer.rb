class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :stocked, :unit, :in_price, :distributor_price, :retail_price, :item_type, :item_group, :vat_add_factor
  has_many :batches, key: :batches
end
