class TransferDecorator < Draper::Decorator
  delegate_all

  def state_change_button
    case object.state
    when 'not_sent'
      h.link_to(
        h.t(:send_package),
        h.send_package_transfer_path(object),
        method: :post,
        class: 'btn btn-info'
      )
    when 'sent'
      h.link_to(
        h.t(:receive_package),
        h.receive_package_transfer_path(object),
        method: :post,
        class: 'btn btn-success'
      )
    when 'received'
      ' '
    end
  end

end
