class Unit < ActiveRecord::Base

  # t.string  :name
  # t.string  :weight
  # t.string  :package_dimensions

  attr_accessible :name, :weight, :package_dimensions

  has_many :items

  validates :name, :uniqueness => true
  validates :name, :presence => true

  private
  
end