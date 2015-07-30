class VerificateItemDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  def debit
    number_with_precision(object.debit, precision: 2)
  end
  def credit
    number_with_precision(object.credit, precision: 2)
  end

  def result_unit_name
    object.result_unit ? object.result_unit.name : ''
  end
end
