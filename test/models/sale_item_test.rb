require 'test_helper'

class SaleItemTest < ActiveSupport::TestCase
  def setup
    DatabaseCleaner.clean
    Sale.destroy_all
  end

  test "sale_item must have price an quantities" do
    sale_item = SaleItem.new
    assert_not sale_item.valid?
    assert_equal [:quantity, :price], sale_item.errors.keys
  end
end
