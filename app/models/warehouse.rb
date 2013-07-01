class Warehouse < ActiveRecord::Base
  attr_accessible :name, :address, :zip, :city
end
