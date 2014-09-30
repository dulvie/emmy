class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :warehouse_id
      t.datetime :inventory_date
      t.string :state
      t.timestamp :started_at
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
