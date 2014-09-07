# This class takes an product value string and can add the correct
# associations to a sale_item.
class ProductParam
  attr_accessor :model, :model_id

  def initialize(value_string)
    @value_array = value_string.split('_')
    @model = @value_array.first
    @model_id = @value_array.last
  end

  # If the model is a shelf or an item, add that association to the sale_item
  def add_to(sale_item)
    case model
    when 'shelf'
      sale_item.batch_id = Shelf.find(model_id).batch_id
      sale_item.item = sale_item.batch.item
    when 'item'
      sale_item.item_id = model_id
    else
      Rails.logger.info "Unknown productparam model: #{model} / #{id}"
    end
    sale_item
  end
end
