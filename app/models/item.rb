class Item < ActiveRecord::Base

  # t.integer :unit_id
  # t.integer :vat_id
  # t.string  :name
  # t.text    :comment
  # t.string  :item_type
  # t.string  :item_group
  # t.boolean :stocked
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price

  TYPES = ['sales', 'purchases', 'both']
  GROUPS = [' ', 'refined', 'unrefined']

  belongs_to :unit
  belongs_to :vat
  has_many :products
  has_many :purchase_items

  attr_accessible :name, :comment, :item_type, :item_group, :stocked, :unit_id,
  :in_price, :distributor_price, :retail_price, :vat_id

  validates :name, :uniqueness => true
  validates :name, :presence => true
  validates :unit, :presence => true
  validates :vat_id, :presence => true # Needed for other models as well.

  validates :item_type, inclusion: {in: TYPES}
  validates :item_group, inclusion: {in: GROUPS}

  def can_delete?
    return false if products.size > 0
    return false if purchase_items.size > 0
    true
  end

end
