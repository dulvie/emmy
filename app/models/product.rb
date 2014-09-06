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

end
