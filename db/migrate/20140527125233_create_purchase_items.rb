class CreatePurchaseItems < ActiveRecord::Migration
  def change
    create_table :purchase_items do |t|
      t.integer :organization_id
      t.integer :purchase_id
      t.integer :item_id
      t.integer :batch_id
      t.integer :quantity
      t.integer :price
      t.integer :amount
      t.integer :vat

      t.timestamps
    end
  end
end
