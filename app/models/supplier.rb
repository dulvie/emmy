class Supplier < ActiveRecord::Base
  # t.string  :name
  # t.integer :orgnr
  # t.string  :address
  # t.string  :zip
  # t.string  :city
  # t.string  :bg_number
  # t.string  :vat_number

  has_one :contact_info
  has_many :comments, as: :parent

  attr_accessible :name, :orgnr, :address, :zip, :city, :bg_number, :vat_number

  validate :name, presence: true
end
