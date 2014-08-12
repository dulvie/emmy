class SaleItemDecorator < Draper::Decorator
  delegate_all

  def batch_name
    return batch.name if batch
    return (:unknown_batch_name)
  end
end
