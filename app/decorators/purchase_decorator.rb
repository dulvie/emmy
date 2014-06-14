class PurchaseDecorator < Draper::Decorator
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
    when 'not_received'
      l = 'warning'
      str = h.t(:not_received)
    when 'received'
      l = 'success'
      str = h.t(:received)
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

  def supplier_name
    object.supplier.name
  end

  def supplier_email
    object.supplier.email
  end

  def warehouse_name
    object.to_warehouse.name
  end

end

