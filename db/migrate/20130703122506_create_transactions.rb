class CreateTransactions  < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :parent_type
      t.integer :parent_id
      t.integer :product_id
      t.integer :warehouse_id
      t.integer :quantity

      t.timestamps
    end
  end
end
