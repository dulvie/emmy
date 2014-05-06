class Customer < ActiveRecord::Base
  # t.string  :name
  # t.integer :orgnr
  # t.string  :address
  # t.string  :zip
  # t.string  :city

  has_one :contact_info
  has_many :comments, as: :parent

  attr_accessible :name, :orgnr, :address, :zip, :city

  validates :name, presence: true
end
