class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.integer :organisation_id
      t.integer :inventory_id
      t.integer :batch_id
      t.integer :shelf_quantity
      t.integer :actual_quantity

      t.timestamps
    end
  end
end
