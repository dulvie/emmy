class Customer < ActiveRecord::Base
  # t.string :name
  # t.string :orgnr

  attr_accessible :name, :orgnr

  has_one :contact_info

  validate :name, presence: true
end
