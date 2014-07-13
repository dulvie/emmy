require 'test_helper'

class UnitTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.clean
    Unit.destroy_all
  end

  test "unit must have a name" do
    unit = Unit.new
    assert unit.invalid?
    assert unit.errors[:name].any?
  end

  test "unit name must be unique" do
    u1 = Unit.new(name: 'u_name')
    assert u1.save
    assert u1.errors.empty?
    u2 = Unit.new(name: 'u_name')
    assert_not u2.save
    assert u2.errors[:name].any?
  end

end
