class ReversedVatDecorator < Draper::Decorator
  delegate_all

  def vat_from
    return l(object.vat_from, format: '%Y-%m-%d') if object.vat_from
    ''
  end

  def vat_to
    return l(object.vat_to, format: '%Y-%m-%d') if object.vat_to
    ''
  end

  def deadline
    return l(object.deadline, format: '%Y-%m-%d') if object.deadline
    ''
  end

  def state
    l = 'default'
    case object.state
    when 'preliminary'
      l = 'info'
      str = h.t(:preliminary)
    when 'start_calculation'
        l = 'danger'
        str = h.t(:calculation_in_progress)
    when 'calculated'
      l = 'warning'
      str = h.t(:calculated)
    when 'reported'
      l = 'success'
      str = h.t(:reported)
   end
    h.labelify(str, l)
  end
end
