class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.integer :inventory_id
      t.integer :product_id
      t.integer :shelf_quantity
      t.integer :actual_quantity

      t.timestamps
    end
  end
end
