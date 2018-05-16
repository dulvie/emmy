class SimplifiedSaleDecorator < Draper::Decorator
  delegate_all

  def posting_date
    return l(object.posting_date, format: '%Y-%m-%d') if object.posting_date
    ''
  end
end
