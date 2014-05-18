class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :vat_number, :address, :zip, :city
end
