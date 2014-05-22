require 'test_helper'

class TransferTest < ActiveSupport::TestCase
  def setup
    puts "running setup"
    DatabaseCleaner.clean
    User.destroy_all
    Role.destroy_all
    Warehouse.destroy_all
    Product.destroy_all
  end

  test "creation and completion of a transfer" do
    user = FactoryGirl.create :user
    qty = 50
    from_warehouse= FactoryGirl.create :warehouse
    to_warehouse = FactoryGirl.create :warehouse, name: 'to_warehouse'
    product = FactoryGirl.create :product
    assert_equal 0, from_warehouse.shelves.count
    assert_equal 0, to_warehouse.shelves.count

    t = ProductTransaction.new product_id: product.id, warehouse_id: from_warehouse.id, quantity: qty
    t.save!
    Resque.run!
    # ensure we have env setup properly.
    assert_equal qty, from_warehouse.shelves.where(product_id: product.id).first.quantity

    transfer = Transfer.new(
      from_warehouse_id: from_warehouse.id,
      to_warehouse_id: to_warehouse.id,
      user_id: user.id,
      product_id: product.id,
      quantity: qty
    )
    transfer.save
    assert_equal 'not_sent', transfer.state
    assert_nil transfer.from_transaction
    assert_nil transfer.to_transaction

    transfer.send_package
    Resque.run!
    assert_equal 'sent', transfer.state
    assert transfer.from_transaction
    assert_equal 0, from_warehouse.shelves.where(product_id: product.id).first.quantity
    assert_nil transfer.to_transaction

    transfer.receive_package
    Resque.run!
    assert_equal 'received', transfer.state
    assert transfer.to_transaction
    assert_equal qty, to_warehouse.shelves.where(product_id: product.id).first.quantity
  end
end
