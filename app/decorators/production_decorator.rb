class ProductionDecorator < Draper::Decorator
  delegate_all

  def states
    [pretty_state]
  end

  def pretty_state
    l = 'default'
    case object.state
    when 'not_started'
      l = 'info'
      str = h.t(:not_started)
    when 'started'
      l = 'warning'
      str = h.t(:started)
    when 'completed'
      l = 'success'
      str = h.t(:completed)
    end
    labelify(str, l)
  end


  def labelify(str, label_state)
    h.content_tag :span, class: "label label-#{label_state}" do
      str
    end
  end

  def parent_type
    object
  end

  def delete_button
    return unless object.can_delete?
    h.link_to h.delete_icon, object, method: :delete, data: { confirm: 'Are you Sure?' }
  end


end

