class Job::ProductTransactionDestroyEvent
  @queue = :product_transaction_events

  def self.perform(warehouse_id, product_id)
    Rails.logger.info "ProductTransactionDestroyEvent.perform(#{warehouse_id} #{product_id})"
    wh = Warehouse.find(warehouse_id)
    shelf = wh.shelves.where(product_id: product_id).first
    shelf.recalculate
  end

end
