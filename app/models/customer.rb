class Customer < ActiveRecord::Base

  attr_accessible :name, :orgnr

  has_one :contact_info

  validate :name, presence: true
end
