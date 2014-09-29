require 'test_helper'

class BatchTest < ActiveSupport::TestCase
  def setup
    DatabaseCleaner.clean
    Batch.destroy_all
  end

  test "Saving price as integer" do
    b = Batch.new(name: "foobar", in_price: 1000)
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
