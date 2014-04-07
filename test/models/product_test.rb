require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Saving price as integer" do
    p = Product.new(name: "foobar", product_type: 'refined', in_price: 1000)
    p.save
    p = Product.find_by_name "foobar"
    assert p.in_price.eql?(1000)
    decorated = p.decorate
    assert_equal decorated.in_price, "10.00"
  end

end
