class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :vat_number, :address, :zip, :city, :payment_term

  has_many :contacts
end
