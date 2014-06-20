require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  def setup
    DatabaseCleaner.clean
    Product.destroy_all
  end

  test "Saving price as integer" do
    p = Product.new(name: "foobar", in_price: 1000, vat: 12)
    unless p.save
      puts p.errors.full_messages
      assert p.save
    end
    assert p.persisted?
    p = Product.find_by_name "foobar"
    assert p.in_price.eql?(1000)
    decorated = p.decorate
    assert_equal decorated.in_price, "10.00"
  end

end
