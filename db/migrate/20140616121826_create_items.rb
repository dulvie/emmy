class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|

        t.integer :unit_id

        t.string :name
        t.text :comment
        t.string :item_type
        t.string :item_group
        t.boolean :stocked
        t.integer :in_price
        t.integer :distributor_price
        t.integer :retail_price
        t.integer :vat

       t.timestamps

    end
  end
end
