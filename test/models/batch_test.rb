require 'test_helper'

class BatchTest < ActiveSupport::TestCase
  def setup
    DatabaseCleaner.clean
    Batch.destroy_all
  end

  test "unique name/organization_id scope" do
    name = 'foobar'
    b = Batch.new(name: name)
    b.item = Item.new
    b.organization_id = 1

    assert b.save

    b2 = Batch.new(name: name)
    b2.item = Item.new
    b2.organization_id = 1

    assert((!b2.save), "should not be able to save b2: #{b2.inspect}")
    assert((b2.errors.has_key? :name), "should have error on name: #{b2.errors.keys.inspect}")
    b2.organization_id = 2
    assert b2.save

  end

  test "Saving price as integer" do
    b = Batch.new(name: "foobar", in_price: 1000)
    b.item = Item.new
    unless b.save
      puts b.errors.full_messages
      assert b.save
    end
    assert b.persisted?
    b = Batch.find_by_name "foobar"
    assert b.in_price.eql?(1000)
    decorated = b.decorate
    assert_equal decorated.in_price, "10.00"
  end

end
