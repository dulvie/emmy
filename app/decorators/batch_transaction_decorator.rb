class BatchTransactionDecorator < Draper::Decorator
  delegate_all
  def parent_path
    Rails.logger.info "parentpath: #{object.inspect}"
    case parent_type
    when 'Transfer'
      h.transfer_path(object.parent_id)
    when 'Manual'
      h.manual_path(object.parent_id)
    else
      ""
    end
  end
end