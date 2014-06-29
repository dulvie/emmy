class Product < ActiveRecord::Base

  # t.integer :item_id

  # t.string :name
  # t.text :comment
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price

  # t.timestamp :refined_at
  # t.timestamp :expire_at
  
  belongs_to :item
  has_many :transactions
  has_many :shelves, through: :transactions

  attr_accessible :item_id, :name, :comment, :in_price, :distributor_price, :retail_price, 
    :expire_at, :refined_at

  delegate :item_group, :vat, :unit, to: :item

  validates :name, :uniqueness => true
  validates :name, :presence => true
  validates :item, :presence => true
  
  def can_delete?
    return false if Shelf.where('product_id' => self.id).size > 0
    return true
  end

  def quantity
    qty = Shelf.where('product_id' => self.id).sum('quantity')
    return qty
  end
end
