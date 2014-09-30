class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :from_warehouse_id
      t.integer :to_warehouse_id
      t.integer :batch_id
      t.integer :quantity
      t.integer :user_id
      t.integer :organization_id

      t.string  :state
      t.timestamp :sent_at
      t.timestamp :received_at

      t.timestamps
    end
  end
end
