class Product
  attr_accessor :value, :name, :available_quantity, :stocked,
                :distributor_price, :retail_price, :refined_at, :expire_at,
                :selected, :organization

  def initialize(h = {})
    setup_defaults
    h.each { |k, v| instance_variable_set("@#{k}", v) }
  end

  def setup_defaults
    @selected = false
    @retail_price = 0
    @distributor_price = 0
    @available_quantity = 1
  end

  def self.find_using_shelves(current_organization, shelves)
    products = shelves.map { |s| s.to_product }
    non_shelf_items = current_organization.items.sellable.not_stocked.map { |i| i.to_product }
    products += non_shelf_items
    products
  end
end
