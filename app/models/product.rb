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

  # @todo Add option to upload image of the package.
end
