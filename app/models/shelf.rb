class Shelf < ActiveRecord::Base
  # t.integer :quantity
  # t.integer :warehouse_id
  # t.integer :batch_id

  belongs_to :warehouse
  belongs_to :batch

  attr_accessible :quantity, :batch_id, :warehouse_id

  validates :batch_id, presence: true
  validates :warehouse_id, presence: true

  delegate :name, :in_price, :distributor_price, :retail_price, :vat, :unit, :item_group, to: :batch

  def outgoing
    Sale.where('state' => 'item_complete', 'goods_state' => 'not_delivered').joins(:sale_items).where('sale_items.batch_id' => self.batch_id).sum('quantity')
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
