require 'test_helper'

class CustomerTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.clean
    Customer.destroy_all
  end

  test "customer must have a unique name" do
    customer = Customer.new
    assert_not customer.valid?
    customer = Customer.new(name: 'c_name')
    assert customer.errors.empty?
    c2 = Customer.new(name: 'c_name')
    assert_not c2.save
    assert c2.errors[:name].any?
  end

end
