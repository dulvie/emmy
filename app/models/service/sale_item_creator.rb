class Service::SaleItemCreator
  include ActiveModel::Model

  attr_accessor :attributes

  def initialize(sale, sale_item, params)
    @sale = sale
    @sale_item = sale_item
    @params = params
    @attributes = {}
  end

  def add_params
    value_array = @params[:product_value].split('_')
    if value_array.first.eql? 'batch'
      @sale_item.batch_id = value_array.last
    else
      @sale_item.item_id = value_array.last
    end
  end

  def save
    add_params
    @attributes = @sale_item.attributes
    @sale_item.save
  end

  def to_hash
    attributes
  end
end
