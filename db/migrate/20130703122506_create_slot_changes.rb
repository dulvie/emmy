class CreateSlotChanges < ActiveRecord::Migration
  def change
    create_table :slot_changes do |t|
      t.integer :slot_id
      t.integer :quantity
      t.integer :invoice_item_id
      t.integer :user_id
      t.integer :change_type
      t.integer :current_state

      t.timestamps
    end
  end
end
