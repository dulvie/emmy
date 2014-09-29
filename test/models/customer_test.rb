require 'test_helper'

class CustomerTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.clean
    Customer.destroy_all
  end

  test "customer must have a unique name" do
    customer = Customer.new
    assert_not customer.valid?
    c1 = Customer.new(name: 'c_name', payment_term: 10)
    assert c1.save
    assert c1.errors.empty?
    c2 = Customer.new(name: 'c_name', payment_term: 10)
    assert_not c2.save
    assert c2.errors[:name].any?
  end

end
