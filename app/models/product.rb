class Product < ActiveRecord::Base
  # t.string :name
  # t.text :comment
  # t.string :product_type
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price
  # t.integer :vat
  # t.string :weight
  # t.string :package_dimensions
  # t.timestamp :expire_at
  # t.timestamp :refined_at

  TYPES = ['refined', 'unrefined']

  has_many :slots, through: :slot_changes

  attr_accessible :name, :product_type, :in_price, :distributor_price, :retail_price, :vat, :weight, :expire_at, :refined_at

  validates :name, :uniqueness => true
  validates :name, :presence => true

  validates :product_type, inclusion: {in: TYPES}

end
