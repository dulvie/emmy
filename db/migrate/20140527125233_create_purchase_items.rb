class CreatePurchaseItems < ActiveRecord::Migration
  def change
    create_table :purchase_items do |t|
      t.integer :purchase_id
      t.integer :product_id
      t.integer :quantity
      t.integer :price
      t.integer :price_sum
      t.integer :vat
  
      t.timestamps
    end
  end
end
