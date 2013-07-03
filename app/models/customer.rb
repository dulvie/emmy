class Customer < ActiveRecord::Base
  has_one :contact_info
end
