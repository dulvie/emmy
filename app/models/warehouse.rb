class Warehouse < ActiveRecord::Base
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city

  has_many :shelves, :dependent => :destroy
  has_many :contacts, as: :parent
  has_many :comments, as: :parent
  has_many :manuals
  has_many :transactions

  attr_accessible :name, :address, :zip, :city

end
