class CreateSlotChanges < ActiveRecord::Migration
  def change
    create_table :slot_changes do |t|
      t.integer :slot_id
      t.integer :user_id
      t.integer :quantity
      t.string :change_type
      t.string :current_state
      t.integer :comments_count, :default => 0

      t.timestamps
    end
  end
end
