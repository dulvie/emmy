class Service::SaleItemCreator
  include ActiveModel::Model
  attr_accessor :sale_item, :value

  validates :price, presence: true
  validates :quantity, presence: true

  def initialize(sale, sale_item, params)
    @sale = sale
    @sale_item = sale_item
    @price = @sale_item.price
    @quantity = @sale_item.quantity
    @params = params[:sale_item]
    @value = @params[:product].to_s
  end

  def add_params
    unless @value.empty?
      value_array = @value.split('_')
      if value_array.first.eql? 'batch'
        @sale_item.batch_id = value_array.last
        @sale_item.item = @sale_item.batch.item
      else
        @sale_item.item_id = value_array.last
      end
    else
      # since sale doesn't have an item, it should throw errors.
    end
  end

  def save
    add_params
    @sale_item.save
  end

  def to_hash
    @sale_item.to_hash
  end

  def errors
    @sale_item.errors
  end
end
