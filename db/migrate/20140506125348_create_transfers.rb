class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :from_warehouse_id
      t.integer :to_warehouse_id
      t.integer :product_id
      t.integer :quantity
      t.integer :user_id
      t.string  :state

      t.timestamps
    end
  end
end
