require 'test_helper'

class ProductTransactionEventTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.clean
    Warehouse.destroy_all
    Product.destroy_all
    Resque.reset!
  end

  test "recalculate_shelf" do
    w = FactoryGirl.create :warehouse
    p = FactoryGirl.create :product
    t = ProductTransaction.new product: p, warehouse: w
    assert_equal t.warehouse, w
    assert_equal t.product, p
    t.quantity = 5
    t.save
    Resque.run!
    shelves = w.shelves.where(product_id: p.id)
    assert shelves.size > 0
    assert_equal shelves.first.quantity, 5
  end

end
