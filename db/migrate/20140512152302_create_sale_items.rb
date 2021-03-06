class CreateSaleItems < ActiveRecord::Migration
  def change
    create_table :sale_items do |t|
      t.integer :organization_id
      t.integer :sale_id
      t.integer :item_id
      t.integer :batch_id
      t.string  :name
      t.integer :quantity
      t.integer :price
      t.integer :price_inc_vat
      t.integer :price_sum
      t.integer :vat

      t.timestamps
    end
  end
end
