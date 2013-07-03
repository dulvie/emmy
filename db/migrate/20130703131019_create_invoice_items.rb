class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.string :name

      t.integer :quantity
      t.integer :vat
      t.integer :price

      t.integer :invoice_id
      t.integer :product_id
      t.integer :slot_change_id

      t.timestamps
    end
  end
end
