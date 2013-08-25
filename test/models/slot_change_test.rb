require 'test_helper'

class SlotChangeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  #
  # This unit test is mainly to test the state machine
  #

  test "create a manual slot change" do
    quantity = 100
    change = SlotChange.new_by_change_type(
      :manual,
      :warehouse_id => 1, :slot_id => 1, :quantity => quantity
    )
    change.user_id = 1
    change.initiate_direct
    assert change.state? :direct
  end

  test "create an awaiting slot change" do
    quantity = 100
    change = SlotChange.new_by_change_type(
      :transfer_in,
      :warehouse_id => 1, :slot_id => 1, :quantity => quantity
    )
    change.user_id = 1
    change.initiate_receiving_transfer
    assert change.state? :awaiting_transfer
  end

  test "create an outgoing slot change" do
    quantity = 100
    change = SlotChange.new_by_change_type(
      :transfer_in,
      :warehouse_id => 1, :slot_id => 1, :quantity => quantity
    )
    change.user_id = 1
    change.initiate_transfer
    assert change.state? :doing_transfer
    assert change.transfer_to_slot
    assert change.transfer_to_slot.state? :awaiting_transfer
  end

  test "transition a transfer into a done state" do
    quantity = 100
    change = SlotChange.new_by_change_type(
      :transfer_in,
      :warehouse_id => 1, :slot_id => 1, :quantity => quantity
    )
    change.save
    change_id = change.id
    change.initiate_transfer
    assert change.state? :doing_transfer

    receiver = change.transfer_to_slot

    assert receiver.state? :awaiting_transfer

    receiver.received_transfer


    assert receiver.state? :confirmed_transfer

    # need to re-fetch the change.
    change = SlotChange.find change_id
    assert change.state? :confirmed_transfer
  end

end
