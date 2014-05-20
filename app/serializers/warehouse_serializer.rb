class WarehouseSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :zip, :city
end
