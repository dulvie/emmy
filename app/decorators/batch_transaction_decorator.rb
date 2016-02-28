class BatchTransactionDecorator < Draper::Decorator
  delegate_all
  def parent_path
    Rails.logger.info "parentpath: #{object.inspect}"
    case parent_type
    when 'Transfer'
      h.transfer_path(object.parent_id)
    when 'Manual'
      h.manual_path(object.parent_id)
    when 'Production'
      h.production_path(object.parent_id)
    when 'Sale'
      h.sale_path(object.parent_id)
    else
      ""
    end
  end

  def format_created_at
    return l(object.created_at, format: '%Y-%m-%d') if object.created_at
    ''
  end
end
