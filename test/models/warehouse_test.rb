require 'test_helper'

class WarehouseTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.clean
    Warehouse.destroy_all
  end

  test "warehouse must have a name" do
    warehouse = Warehouse.new
    assert warehouse.invalid?
    assert warehouse.errors[:name].any?
  end

  test "warehouse name must be unique" do
    w1 = Warehouse.new(name: 'wh_name')
    assert w1.save
    assert w1.errors.empty?
    w2 = Warehouse.new(name: 'wh_name')
    assert_not w2.save
    assert w2.errors[:name].any?
  end

end
