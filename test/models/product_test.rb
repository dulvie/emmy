require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Saving price without cents as integer" do
    p = Product.new(name: "foobar", product_type: 'refined', in_price: 100)
    p.save
    p = Product.find_by_name "foobar"
    assert p.in_price.eql?(10000)
    decorated = p.decorate
    assert_equal decorated.in_price, "100.00"
  end

  test "Saving price with cents as integer" do
    p = Product.new(name: "foobar", product_type: 'refined', in_price: 100.00)
    p.save
    p = Product.find_by_name "foobar"
    assert p.in_price.eql?(10000)
    decorated = p.decorate
    assert_equal decorated.in_price, "100.00"
  end

end
