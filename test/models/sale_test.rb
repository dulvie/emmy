require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  def setup
    DatabaseCleaner.clean
    Sale.destroy_all
  end

  test "sale must have a warehouse, customer and payment_term" do
    sale = Sale.new
    assert_not sale.valid?
    assert_equal [:warehouse, :customer, :payment_term], sale.errors.keys
  end

end
