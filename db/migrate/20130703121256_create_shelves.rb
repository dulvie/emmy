class CreateShelves < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.integer :quantity, default: 0
      t.integer :warehouse_id
      t.integer :product_id

      t.timestamps
    end
  end
end
