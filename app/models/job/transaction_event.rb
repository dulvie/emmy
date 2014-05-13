class Job::TransactionEvent
  @queue = :transaction_events

  def self.perform(transaction_id)
    Rails.logger.info "TransactionEvent.perform(#{transaction_id})"
    t = Transaction.find(transaction_id)
    recalculate_shelf(t)
  end

  # Recalculate (cache) the quantity of how many products a warehouse currently has.
  # A new shelf is created if there aren't already one for this warehouse/product combination.
  def self.recalculate_shelf(t)
    shelves = t.warehouse.shelves.where(product_id: t.product_id)
    unless shelves.size > 0
      shelf = Shelf.new(warehouse_id: t.warehouse_id, product_id: t.product_id)
    else
      shelf = shelves.first
    end
    shelf.recalculate
  end
end
