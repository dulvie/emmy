class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|

      t.integer :item_id

      t.string :name
      t.text :comment
      t.string :product_type, default: Product::TYPES.first 

      t.integer :in_price
      t.integer :distributor_price
      t.integer :retail_price
      t.integer :vat

      t.string :unit
      t.string :weight
      t.string :package_dimensions
      t.timestamp :expire_at
      t.timestamp :refined_at

      t.timestamps
    end
  end
end
