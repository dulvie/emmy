class StockValueDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  def value_date
    return l(object.value_date, format: "%Y-%m-%d") if object.value_date
    ""
  end

  def value
    number_with_precision(object.value, precision: 2)
  end
end
