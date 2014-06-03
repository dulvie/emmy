class SaleItemDecorator < Draper::Decorator
  delegate_all

  def product_name
    return product.name if product
    return (:unknown_product_name)
  end
end
