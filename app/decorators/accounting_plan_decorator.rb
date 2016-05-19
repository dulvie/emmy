class AccountingPlanDecorator < Draper::Decorator
  delegate_all

  def states
    return h.labelify('deleted', 'warning') if object.deleted?
    return h.labelify('created', 'warning') if object.created?
    h.labelify('completed', 'success')
  end
end
