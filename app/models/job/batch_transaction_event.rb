class Job::BatchTransactionEvent
  @queue = :batch_transaction_events

  def self.perform(batch_transaction_id)
    Rails.logger.info "BatchTransactionEvent.perform(#{batch_transaction_id})"
    t = BatchTransaction.find(batch_transaction_id)
    recalculate_shelf(t)
  end

  # Recalculate (cache) the quantity of how many batches a warehouse currently has.
  # A new shelf is created if there aren't already one for this warehouse/batch combination.
  def self.recalculate_shelf(t)
    shelves = t.warehouse.shelves.where(batch_id: t.batch_id)
    unless shelves.size > 0
      shelf = Shelf.new(warehouse_id: t.warehouse_id, batch_id: t.batch_id)
      shelf.organization_id = t.organization_id
    else
      shelf = shelves.first
    end
    shelf.recalculate
  end
end
