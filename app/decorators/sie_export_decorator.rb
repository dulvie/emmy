class SieExportDecorator < Draper::Decorator
  delegate_all

  def exported_at
    return l(object.export_date, format: '%Y-%m-%d') if object.export_date
    ''
  end

  def states
    return h.labelify('aktiv', 'warning') if !object.completed?
    h.labelify('completed', 'success')
  end
end
