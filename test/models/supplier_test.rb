require 'test_helper'

class SupplierTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.clean
    Supplier.destroy_all
  end

  test "supplier must have a name, bg_number and vat_number" do
    supplier = Supplier.new
    assert_not supplier.valid?
    assert_equal [:name, :bg_number, :vat_number], supplier.errors.keys
  end

end
