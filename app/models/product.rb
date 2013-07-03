class Product < ActiveRecord::Base
  # t.string :name
  # t.integer :in_price
  # t.integer :out_price
  # t.integer :customer_price
  # t.integer :vat
  # t.string :weight
  # t.timestamp :expire_at
  # t.timestamp :refined_at

  has_and_belongs_to_many :slots

  attr_accessible :name, :in_price, :out_price, :customer_price, :vat, :weight, :expire_at, :refined_at

  validates :name, :uniqueness => true
  validates :name, :presence => true

  # @todo Add option to upload image of the package.
  # @todo Implement state (active, inactive, archived products etc)

  # @todo Refactor into a presenter
  def product_price
    return 0 unless customer_price.to_i > 0

    customer_price + (customer_price * (vat_modifier/100))
  end

  def vat_modifier
    (vat.to_i > 0) ? vat/100 : 0
  end
end
