class Shelf < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :quantity
  # t.integer :warehouse_id
  # t.integer :batch_id

  belongs_to :organisation
  belongs_to :warehouse
  belongs_to :batch

  attr_accessible :quantity, :batch_id, :warehouse_id, :organisation, :organisation_id

  validates :batch_id, presence: true
  validates :warehouse_id, presence: true

  delegate :name, :in_price, :distributor_price, :retail_price, :vat, :unit, :item_group, to: :batch


  def outgoing
    Sale.where('state' => 'prepared', 'goods_state' => 'not_delivered', 'warehouse_id' => self.warehouse_id).joins(:sale_items).where('sale_items.batch_id' => self.batch_id).sum('quantity')
  end

  def incoming
    qty = Purchase.where('state' => 'prepared', 'goods_state' => 'not_received', 'to_warehouse_id' => self.warehouse_id).joins(:purchase_items).where('purchase_items.batch_id' => self.id).sum('quantity')
    ext = Production.where('state' => 'started', 'warehouse_id' => self.warehouse_id, 'batch_id' => self.id).sum('quantity')
    return qty+ext
  end

  # Cache the batch_transaction quantity sum of batch in the warehouse.
  def recalculate
    self.quantity = BatchTransaction.where(warehouse_id: warehouse_id).where(batch_id: batch_id).sum(:quantity)
    save!
    logger.info "OBS! kvantitet: #{self.quantity}"
    if self.quantity == 0
      destroy
    end
  end
end
