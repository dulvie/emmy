class WageDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  def wage_from
    return l(object.wage_from, format: '%Y-%m-%d') if object.wage_from
    ''
  end

  def wage_to
    return l(object.wage_to, format: '%Y-%m-%d') if object.wage_to
    ''
  end

  def payment_date
    return l(object.payment_date, format: '%Y-%m-%d') if object.payment_date
    ''
  end

  def wage_tax
    number_with_precision(object.tax, precision: 2)
  end

  def wage_payroll_tax
    number_with_precision(object.payroll_tax, precision: 2)
  end

  def state
    l = 'default'
    case object.state
    when 'preliminary'
      l = 'info'
      str = h.t(:preliminary)
    when 'calculated'
      l = 'warning'
      str = h.t(:calculated)
    when 'wage_reported'
      l = 'success'
      str = h.t(:reported)
   end
    h.labelify(str, l)
  end
end
