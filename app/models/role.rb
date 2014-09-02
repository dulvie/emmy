class Role < ActiveRecord::Base
  # t.string :name

  has_and_belongs_to_many :users

  attr_accessible :name

  validates_uniqueness_of :name
  validates_presence_of :name
end
