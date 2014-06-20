class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|

      t.integer :item_id

      t.string :name
      t.text :comment

      t.integer :in_price
      t.integer :distributor_price
      t.integer :retail_price

      t.timestamp :refined_at
      t.timestamp :expire_at

      t.timestamps

    end
  end
end
