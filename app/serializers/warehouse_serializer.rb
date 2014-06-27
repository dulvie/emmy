class WarehouseSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :zip, :city
  has_many :shelves
end
