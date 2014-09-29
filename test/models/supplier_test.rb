require 'test_helper'

class SupplierTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.clean
    Supplier.destroy_all
  end

  test "supplier must have a name" do
    supplier = Supplier.new
    assert_not supplier.valid?
    assert_equal [:name], supplier.errors.keys
  end

end
