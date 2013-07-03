class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :comment

      t.integer :in_price
      t.integer :out_price
      t.integer :customer_price
      t.integer :vat

      t.string :weight
      t.string :package_dimensions
      t.timestamp :expire_at
      t.timestamp :refined_at

      t.timestamps
    end
  end
end
