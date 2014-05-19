class SaleDecorator < Draper::Decorator
  delegate_all

  def states
    [pretty_state, pretty_goods_state, pretty_money_state]
  end

  def pretty_state
    l = 'default'
    case object.state
    when 'complete'
      l = 'success'
      str = 'complete'
    when 'incomplete'
      l = 'warning'
      str = 'incomplete'
    end
    labelify(str, l)
  end

  def pretty_goods_state
    l = 'default'
    case object.goods_state
    when 'not_delivered'
      l = 'warning'
      str = h.t(:not_delivered)
    when 'delivered'
      l = 'success'
      str = h.t(:delivered)
    end
    labelify(str, l)
  end

  def pretty_money_state
    l = 'default'
    case object.money_state
    when 'not_paid'
      l = 'danger'
      str = h.t(:not_paid)
    when 'paid'
      l = 'success'
      str = h.t(:paid)
    end
    labelify(str, l)
  end

  def labelify(str, label_state)
    h.content_tag :span, class: "label label-#{label_state}" do
      str
    end
  end

end
