class Warehouse < ActiveRecord::Base
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city

  attr_accessible :name, :address, :zip, :city

  has_many :slots
  has_many :contact_infos
end
