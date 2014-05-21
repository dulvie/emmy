class SaleDecorator < Draper::Decorator
  delegate_all

  def states
    [pretty_state, pretty_goods_state, pretty_money_state]
  end

  def pretty_state
    l = 'default'
    case object.state
    when 'meta_complete'
      l = 'info'
      str = h.t(:has_base_info)
    when 'item_complete'
      l = 'info'
      str = h.t(:item_complete)
    when 'processing'
      l = 'warning'
      str = h.t(:processing)
    when 'completed'
      l = 'success'
      str = h.t(:completed)
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

  def delete_button
    return unless object.can_delete?
    h.link_to h.delete_icon, object, method: :delete, data: { confirm: 'Are you Sure?' }
  end

  def customer_name
    object.customer.name
  end

  def warehouse_name
    object.warehouse.name
  end

end