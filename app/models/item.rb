class Item < ActiveRecord::Base
  # t.integer :organization_id
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

  scope :bayable, -> { where("item_type in (?)", ['purchases','both']) }
  scope :sellable, -> { where("item_type in (?)", ['sales','both']) }
  scope :not_stocked, -> { where(stocked: false) }

  belongs_to :organization
  belongs_to :unit
  belongs_to :vat
  has_many :batches
  has_many :purchase_items

  attr_accessible :name, :comment, :item_type, :item_group, :stocked, :unit_id,
                  :in_price, :distributor_price, :retail_price, :vat_id

  validates :name, presence: true
  validates :unit, presence: true
  validates :vat_id, presence: true # Needed for other models as well.

  validates :item_type, inclusion: { in: TYPES }
  validates :item_group, inclusion: { in: GROUPS }

  def distributor_inc_vat
    return 0 if !distributor_price
    (distributor_price + distributor_price * vat.add_factor)/100
  end

  def retail_inc_vat
    return 0 if !retail_price
    (retail_price + retail_price * vat.add_factor)/100
  end

  def vat_add_factor
    vat.add_factor
  end

  def can_delete?
    return false if batches.size > 0
    return false if purchase_items.size > 0
    true
  end

  def to_product
    Product.new(value: "item_#{id}",
                name: name,
                available_quantity: 1,
                distributor_price: distributor_price,
                retail_price: retail_price,
                distributor_inc_vat: distributor_inc_vat,
                retail_inc_vat: retail_inc_vat,
                vat_add_factor: vat_add_factor,
                stocked: false)
  end
end
