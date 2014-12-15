class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :vat_number, :address, :zip, :city, :email, :payment_term, :primary_contact_id
  has_many :contacts
end
