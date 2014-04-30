class Customer < ActiveRecord::Base
  # t.string :name
  # t.string :orgnr

  has_one :contact_info

  attr_accessible :name, :orgnr

  validate :name, presence: true
end
