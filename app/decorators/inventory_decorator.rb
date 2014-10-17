class InventoryDecorator < Draper::Decorator
  delegate_all

  def states
    [pretty_state]
  end

  def pretty_state
    l = 'default'
    case object.state
    when 'started'
      l = 'info'
      str = h.t(:started)
    when 'not_started'
      l = 'warning'
      str = h.t(:not_started)
    when 'completed'
      l = 'success'
      str = h.t(:completed)
    else
      l = 'danger'
      str = h.t(:unknown)
    end
    h.labelify(str, l)
  end
end
