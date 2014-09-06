class Product
  attr_accessor :value, :name, :available_quantity, :stocked,
    :distributor_price, :retail_price, :refined_at, :expire_at

  def initialize(h = {})
    h.each {|k,v| instance_variable_set("@#{k}",v)}
  end

end
