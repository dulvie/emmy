#
# A subgroup of item. All items with stocked true
#
class Batch < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :item_id

  # t.string :name
  # t.text :comment
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price

  # t.timestamp :refined_at
  # t.timestamp :expire_at

  belongs_to :organization
  belongs_to :item
  has_many :batch_transactions
  has_many :shelves, through: :batch_transactions
  has_one :production

  #attr_accessible :item_id, :name, :comment, :in_price, :distributor_price, :retail_price,
  #                :expire_at, :refined_at

  delegate :item_group, :vat, :unit, to: :item

  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :item, presence: true

  def distributor_inc_vat
    return 0 if !distributor_price || !vat
    (distributor_price + distributor_price * vat.add_factor)/100
  end

  def retail_inc_vat
    return 0 if !retail_price || !vat
    (retail_price + retail_price * vat.add_factor)/100
  end
  
  def vat_add_factor
    vat.add_factor
  end

  def can_delete?
    return false if organization.shelves.where('batch_id' => id).size > 0
    return false if organization.imports.where('batch_id = ? and state = ? ', id, 'started').count > 0
    return false if organization.productions.where('batch_id = ? and state = ? ', id, 'started').count > 0
    return false if organization.sale_items.where('batch_id = ? ', id).count > 0
    return false if organization.purchase_items.where('batch_id = ? ', id).count > 0
    true
  end

  def quantity
    qty = organization.shelves.where('batch_id' => id).sum('quantity')
    ext = organization.transfers.where('state' => 'sent', 'batch_id' => id).sum('quantity')
    qty + ext
  end

  def inventory_price
    price = 0
    import = organization.imports.where('batch_id = ?', id).first
    price = production.cost_price if production
    price = import.cost_price if import
    price = in_price / 100 if price == 0 && in_price
    return price
  end

  def in_quantity
    qty = organization.purchases.prepared.not_received
      .joins(:purchase_items)
      .where('purchase_items.batch_id' => id)
      .sum(:quantity)

    ext = 0
    ext = production.quantity if production && production.started?
    qty + ext
  end

  def out_quantity
    qty = organization.sales.prepared.not_delivered
      .joins(:sale_items)
      .where('sale_items.batch_id' => id)
      .sum(:quantity)
    qty
  end
end
