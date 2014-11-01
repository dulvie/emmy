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

  attr_accessible :item_id, :name, :comment, :in_price, :distributor_price, :retail_price,
                  :expire_at, :refined_at, :organization, :organization_id

  delegate :item_group, :vat, :unit, to: :item

  validates :name, uniqueness: true, if: :inside_organization
  validates :name, presence: true
  validates :item, presence: true

  def inside_organization
    if new_record?
      return true if Batch.where('organization_id = ? and name = ?', organization_id, name).size > 0
    else
      return true if Batch.where('id <> ? and organization_id = ? and name = ?', id, organization_id, name).size > 0
    end
    false
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
