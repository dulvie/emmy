class VerificateDecorator < Draper::Decorator
  delegate_all

  def posting_date
    return l(object.posting_date, format: "%Y-%m-%d") if object.posting_date
    ""
  end

  def parent
    return  h.link_to I18n.t(:sale), h.sale_path(object.parent_id) if object.parent_type == 'Sale'
    return  h.link_to I18n.t(:vat_period), h.vat_period_vat_reports_path(object.parent_id) if object.parent_type == 'VatPeriod'
    return  h.link_to I18n.t(:wage_period), h.wage_period_wages_path(object.parent_id) if object.parent_type == 'WagePeriod' && verificate.parent_extend == 'wage'
    return  h.link_to I18n.t(:wage_period), h.wage_period_wage_reports_path(object.parent_id) if object.parent_type == 'WagePeriod' && verificate.parent_extend == 'tax'
    return  h.link_to I18n.t(:import_bank_file), h.import_bank_file_path(object.parent.import_bank_file_id) if object.parent_type == 'ImportBankFileRow'
    return  h.link_to I18n.t(:purchase), h.purchase_path(object.parent_id) if object.parent_type == 'Purchase'
    return ' '
  end

  def total_debit
    number_with_precision(object.total_debit, precision: 2)
  end
  def total_credit
    number_with_precision(object.total_credit, precision: 2)
  end
  def pretty_state
    l = 'default'
    case object.state
      when 'preliminary'
        l = 'info'
        str = h.t(:preliminary)
      when 'final'
        l = 'success'
        str = h.t(:final)
     end
    h.labelify(str, l)
  end
end
