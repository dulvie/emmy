class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.integer :organization_id
      t.integer :inventory_id
      t.integer :batch_id
      t.integer :shelf_quantity
      t.integer :actual_quantity
      t.boolean :reported

      t.timestamps
    end
  end
end
