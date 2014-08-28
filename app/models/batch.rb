#
# A subgroup of item. All items with stocked true
#
class Batch < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :item_id

  # t.string :name
  # t.text :comment
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price

  # t.timestamp :refined_at
  # t.timestamp :expire_at

  belongs_to :organisation
  belongs_to :item
  has_many :batch_transactions
  has_many :shelves, through: :batch_transactions
  has_one :production

  attr_accessible :item_id, :name, :comment, :in_price, :distributor_price, :retail_price,
                  :expire_at, :refined_at, :organisation, :organisation_id

  delegate :item_group, :vat, :unit, to: :item

  validates :name, uniqueness: true
  validates :name, presence: true
  validates :item, presence: true

  def can_delete?
    return false if Shelf.where('batch_id' => id).size > 0
    return false if Import.where('batch_id = ? and state = ? ', id, 'started').count > 0
    return false if Production.where('batch_id = ? and state = ? ', id, 'started').count > 0
    return false if SaleItem.where('batch_id = ? ', id).count > 0
    return false if PurchaseItem.where('batch_id = ? ', id).count > 0
    true
  end

  def quantity
    qty = Shelf.where('batch_id' => id).sum('quantity')
    ext = Transfer.where('state' => 'sent', 'batch_id' => id).sum('quantity')
    qty + ext
  end

  def in_quantity
    qty = Purchase.prepared.not_received
      .joins(:purchase_items)
      .where('purchase_items.batch_id' => id)
      .sum(:quantity)

    ext = 0
    ext = production.quantity if production && production.started?
    qty + ext
  end

  def out_quantity
    qty = Sale.prepared.not_delivered
      .joins(:sale_items)
      .where('sale_items.batch_id' => id)
      .sum(:quantity)
    qty
  end
end
