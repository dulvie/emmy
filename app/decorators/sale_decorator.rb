class SaleDecorator < Draper::Decorator
  delegate_all

  def states
    [object.state, pretty_goods_state, pretty_money_state].join(" / ")
  end

  def pretty_goods_state
    case object.goods_state
    when 'not_delivered'
      h.t(:not_delivered)
    when 'delivered'
      h.t(:delivered)
    end
  end

  def pretty_money_state
    case object.money_state
    when 'not_paid'
      h.t(:not_paid)
    when 'paid'
      h.t(:paid)
    end
  end

end
