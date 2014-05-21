class Customer < ActiveRecord::Base
  # t.string  :name
  # t.integer :vat_number
  # t.string  :address
  # t.string  :zip
  # t.string  :city

  has_one :contact_info
  has_many :comments, as: :parent

  attr_accessible :name, :vat_number, :address, :zip, :city

  validates :name, presence: true

  # @TODO implement
  def primary_email
    "email@example.com"
  end
end
