class Customer < ActiveRecord::Base
  # t.string  :name
  # t.integer :vat_number
  # t.string  :address
  # t.string  :zip
  # t.string  :city

  has_many :contact_infos
  has_many :comments, as: :parent

  attr_accessible :name, :vat_number, :address, :zip, :city

  validates :name, presence: true

  def primary_email
    "tbd@implement.now"
  end
end
