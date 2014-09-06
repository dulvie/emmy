class Service::SaleItemCreator
  include ActiveModel::Model
  attr_accessor :attributes

  validates :price, presence: true
  validates :quantity, presence: true

  def initialize(sale, sale_item, params)
    @sale = sale
    @sale_item = sale_item
    @params = params
    @attributes = {}
  end

  def add_params
    if @params[:product]
      value_array = @params[:product].split('_')
      if value_array.first.eql? 'batch'
        @sale_item.batch_id = value_array.last
        @sale_item.item = @sale.batch.item
      else
        @sale_item.item_id = value_array.last
      end
    else
      # since sale doesn't have an item, it should throw errors.
    end
  end

  def save
    @attributes = @sale_item.attributes
    @sale_item.save
  end

  def to_hash
    attributes
  end

  def errors
    @sale_item.errors
  end
end
