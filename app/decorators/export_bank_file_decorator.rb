class ExportBankFileDecorator < Draper::Decorator
  delegate_all

  def export_date
    return l(object.export_date, format: "%Y-%m-%d") if object.export_date
    ""
  end

  def from_date
    return l(object.from_date, format: "%Y-%m-%d") if object.from_date
    ""
  end

  def to_date
    return l(object.to_date, format: "%Y-%m-%d") if object.to_date
    ""
  end
end
