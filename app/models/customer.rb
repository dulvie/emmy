class Customer < ActiveRecord::Base

  attr_accessible :name

  has_one :contact_info
end
