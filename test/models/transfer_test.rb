require 'test_helper'

class TransferTest < ActiveSupport::TestCase
  def setup
    puts "running setup"
    DatabaseCleaner.clean
    User.destroy_all
    Role.destroy_all
    Warehouse.destroy_all
    Batch.destroy_all
  end

  test "creation and completion of a transfer" do
    user = FactoryBot.create :user
    qty = 50
    from_warehouse= FactoryBot.create :warehouse, name: 'from_warehouse'
    to_warehouse = FactoryBot.create :warehouse, name: 'to_warehouse'
    unit = FactoryBot.create :unit
    vat = FactoryBot.create :vat
    item = FactoryBot.create :item, unit: unit, vat: vat
    batch = FactoryBot.create :batch, item_id: item.id
    assert_equal 0, from_warehouse.shelves.count
    assert_equal 0, to_warehouse.shelves.count

    t = BatchTransaction.new batch: batch, warehouse: from_warehouse, quantity: qty
    t.save!
    Resque.run!
    # ensure we have env setup properly.
    assert_equal qty, from_warehouse.shelves.where(batch: batch).first.quantity

    transfer = Transfer.new(
      from_warehouse_id: from_warehouse.id,
      to_warehouse_id: to_warehouse.id,
      batch_id: batch.id,
      quantity: qty-1
    )
    transfer.comments.build(user_id: user.id, body: "Test transaction")
    transfer.save
    assert_equal 'not_sent', transfer.state
    assert_nil transfer.from_transaction
    assert_nil transfer.to_transaction

    date_now = Time.now
    transfer.send_package(date_now)
    Resque.run!
    assert_equal 'sent', transfer.state
    assert transfer.from_transaction
    assert_equal 1, from_warehouse.shelves.where(batch: batch).first.quantity
    assert_nil transfer.to_transaction

    transfer.receive_package(date_now)
    Resque.run!
    assert_equal 'received', transfer.state
    assert transfer.to_transaction
    assert_equal qty-1, to_warehouse.shelves.where(batch: batch).first.quantity
  end
end
