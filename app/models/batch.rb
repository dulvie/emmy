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
  has_many :transactions
  has_many :shelves, through: :transactions

  attr_accessible :item_id, :name, :comment, :in_price, :distributor_price, :retail_price,
    :expire_at, :refined_at, :organisation, :organisation_id

  delegate :item_group, :vat, :unit, to: :item

  validates :name, :uniqueness => true
  validates :name, :presence => true
  validates :item, :presence => true

  def can_delete?
    return false if Shelf.where('batch_id' => self.id).size > 0
    return false if Import.where('batch_id = ? and state = ? ', self.id, 'started').count > 0
    return false if Production.where('batch_id = ? and state = ? ', self.id, 'started').count > 0
    return false if SaleItem.where('batch_id = ? ', self.id).count > 0
    return false if PurchaseItem.where('batch_id = ? ', self.id).count > 0
    return true
  end

  def quantity
    qty = Shelf.where('batch_id' => self.id).sum('quantity')
    ext = Transfer.where('state' => 'sent', 'batch_id' => self.id).sum('quantity')
    return qty+ext
  end

  def in_quantity
    qty = Purchase.where('state' => 'item_complete', 'goods_state' => 'not_received').joins(:purchase_items).where('purchase_items.batch_id' => self.id).sum('quantity')
    ext = Production.where('state' => 'started', 'batch_id' => self.id).sum('quantity')
    return qty+ext
  end

  def out_quantity
    qty = Sale.where('state' => 'item_complete', 'goods_state' => 'not_delivered').joins(:sale_items).where('sale_items.batch_id' => self.id).sum('quantity')
    return qty
  end

end
