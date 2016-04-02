class SieImportDecorator < Draper::Decorator
  delegate_all

  def import_date
    return l(object.import_date, format: '%Y-%m-%d') if object.import_date
    ''
  end

  def states
    return h.labelify('active', 'warning') if !object.completed?
    h.labelify('completed', 'success')
  end
end
