class SupplierSerializer < ActiveModel::Serializer
  attributes :id, :name, :vat_number, :address, :zip, :city, :primary_contact_id
  has_many :contacts
end
