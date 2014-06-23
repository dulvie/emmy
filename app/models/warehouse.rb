class Warehouse < ActiveRecord::Base
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city

  has_many :shelves, :dependent => :destroy
  has_many :contacts, as: :parent
  has_many :comments, as: :parent
  has_many :manuals
  has_many :product_transactions

  attr_accessible :name, :address, :zip, :city

  validates :name, :uniqueness => true
  validates :name, :presence => true

  def products_in_stock
    @products_in_stock ||= shelves.includes(:product).collect{|s| s.product}
  end

  def can_delete?
    return false if  products_in_stock.size > 0
    true
  end

end
