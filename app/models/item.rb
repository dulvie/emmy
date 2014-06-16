class Item < ActiveRecord::Base

  # t.integer :unit_id
  # t.string :name
  # t.text :comment
  # t.string :item_type
  # t.string :item_group
  # t.boolean :stocked
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price
  # t.integer :vat

  TYPES = ['sales', 'purchases', 'both']
  GROUPS = [' ', 'refined', 'unrefined']
  VATS = [0, 12, 25]
     
  belongs_to :unit
  has_many :products
 
  attr_accessible :name, :comment, :item_type, :item_group, :stocked, :unit_id,
  :in_price, :distributor_price, :retail_price, :vat

  validates :name, :uniqueness => true
  validates :name, :presence => true
  validates :vat, :presence => true # Needed for other models as well.

  validates :item_type, inclusion: {in: TYPES}
  validates :item_group, inclusion: {in: GROUPS}
  validates :vat, inclusion: {in: VATS}
  
end
