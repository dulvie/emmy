class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.integer :quantity
      t.text :comment
      t.integer :warehouse_id
      t.integer :product_id

      t.timestamps
    end
  end
end
