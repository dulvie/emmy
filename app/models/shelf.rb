class Shelf < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :quantity
  # t.integer :warehouse_id
  # t.integer :batch_id

  belongs_to :organization
  belongs_to :warehouse
  belongs_to :batch

  attr_accessible :quantity, :batch_id, :warehouse_id, :organization, :organization_id

  validates :batch_id, presence: true
  validates :warehouse_id, presence: true

  delegate :name, :in_price, :distributor_price, :retail_price, :vat, :unit, :item_group, to: :batch

  def outgoing
    Sale.where('state' => 'prepared', 'goods_state' => 'not_delivered', 'warehouse_id' => warehouse_id).joins(:sale_items).where('sale_items.batch_id' => batch_id).sum('quantity')
  end

  def incoming
    qty = Purchase.where('state' => 'prepared', 'goods_state' => 'not_received', 'to_warehouse_id' => warehouse_id).joins(:purchase_items).where('purchase_items.batch_id' => id).sum('quantity')
    ext = Production.where('state' => 'started', 'warehouse_id' => warehouse_id, 'batch_id' => id).sum('quantity')
    qty + ext
  end

  # Cache the batch_transaction quantity sum of batch in the warehouse.
  def recalculate
    self.quantity = BatchTransaction.where(warehouse_id: warehouse_id).where(batch_id: batch_id).sum(:quantity)
    save!
    logger.info "OBS! kvantitet: #{quantity}"
    if quantity == 0
      destroy
    end
  end

  def to_product
    Product.new(value: "shelf_#{id}",
                name: batch.name,
                available_quantity: quantity,
                distributor_price: batch.distributor_price,
                retail_price: batch.retail_price,
                stocked: true)
  end
end
