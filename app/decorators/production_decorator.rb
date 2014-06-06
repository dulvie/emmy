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
    when 'processing'
      l = 'warning'
      str = h.t(:processing)
    when 'complete'
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

  def delete_button
    return unless object.can_delete?
    h.link_to h.delete_icon, object, method: :delete, data: { confirm: 'Are you Sure?' }
  end


end

