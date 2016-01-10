module Services
  class StockValueCreator
    def initialize(organization, user, stock_value)
      @user = user
      @organization = organization
      @stock_value = stock_value
    end

    def recalculate
      total = @stock_value.stock_value_items.sum(:value)
      @stock_value.value = total
      @stock_value.save
    end

    def create_stock_value_items
      # OBS Aktuell kvantitet vid ett value_date
      shelves = @organization.shelves
      shelves.each do |shelf|
        price = shelf.batch.inventory_price
        save_stock_value_item(shelf.warehouse, shelf.batch, price, shelf.quantity)
      end
      recalculate
    end

    def save_stock_value_item(warehouse, batch, price, quantity)
      stock_value_item = @stock_value.stock_value_items.build
      stock_value_item.organization = @organization
      stock_value_item.warehouse = warehouse
      stock_value_item.batch = batch
      stock_value_item.price = price
      stock_value_item.quantity = quantity
      stock_value_item.name = batch.name
      stock_value_item.save
    end
  end
end
