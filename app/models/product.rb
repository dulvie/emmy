class Product
  attr_accessor :value, :name, :available_quantity, :stocked,
    :distributor_price, :retail_price, :refined_at, :expire_at,
    :selected

  def initialize(h = {})
   setup_defaults
    h.each {|k,v| instance_variable_set("@#{k}",v)}
  end

  def setup_defaults
    @selected = false
    @retail_price = 0
    @distributor_price = 0
    @available_quantity = 1
  end

  def self.find_using_shelves(shelves)
    products = shelves.collect{|s| s.to_product }
    non_shelf_items = Item.sellable.not_stocked.collect{|i| i.to_product }
    products += non_shelf_items
    products
  end
end
