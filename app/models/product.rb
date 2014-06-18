class Product < ActiveRecord::Base

  # t.integer :item_id
  # t.string :name
  # t.text :comment
  # t.string :product_type
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price
  # t.integer :vat
  # t.string :weight
  # t.string :unit
  # t.string :package_dimensions
  # t.timestamp :expire_at
  # t.timestamp :refined_at

  TYPES = ['refined', 'unrefined']

  belongs_to :item
  has_many :transactions
  has_many :shelves, through: :transactions

  attr_accessible :item_id, :name, :product_type, :in_price, :distributor_price, :retail_price, :vat, :unit, :weight, :expire_at, :refined_at

  validates :name, :uniqueness => true
  validates :name, :presence => true
  validates :vat, :presence => true # Needed for other models as well.

  validates :product_type, inclusion: {in: TYPES}

end
