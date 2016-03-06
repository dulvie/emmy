class ProductionBatchDecorator < Draper::Decorator
  delegate_all

  def distributor_inc_vat
    return 0
  end

  def retail_inc_vat
    return 0
  end

end

