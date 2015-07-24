class CreateStockValueItems  < ActiveRecord::Migration
  def change
    create_table :stock_value_items do |t|
      t.string   :name
      t.decimal  :price, precision: 11, scale: 2, default: 0.00
      t.integer  :quantity
      t.integer  :value
      t.integer  :organization_id
      t.integer  :stock_value_id
      t.integer  :warehouse_id
      t.integer  :batch_id

      t.timestamps
    end
  end
end
