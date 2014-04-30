class Warehouse < ActiveRecord::Base
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city

  has_many :slots, :dependent => :destroy
  has_many :contact_infos, :dependent => :destroy

  attr_accessible :name, :address, :zip, :city

end
