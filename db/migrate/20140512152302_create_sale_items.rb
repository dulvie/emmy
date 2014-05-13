class CreateSaleItems < ActiveRecord::Migration
  def change
    create_table :sale_items do |t|
      t.integer :sale_id
      t.integer :product_id
      t.integer :quantity
      t.integer :price
      t.integer :price_inc_vat
      t.integer :vat

      t.timestamps
    end
  end
end
