require 'test_helper'

class TransactionEventTest < ActiveSupport::TestCase
  def setup
    Resque.reset!
  end

  def test_recalculate_shelf
    w = FactoryGirl.create :warehouse
    p = FactoryGirl.create :product
    t = Transaction.new product: p, warehouse: w
    t.quantity = 5
    t.save
    assert_queued(Job::TransactionEvent)
    Resque.run!
    shelves = w.shelves.where(product_id: p.id)
    assert shelves.size > 0
    assert_equal shelves.first.quantity, 5
  end

end
