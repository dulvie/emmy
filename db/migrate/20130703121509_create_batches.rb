class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|

      t.integer :item_id
      t.integer :organization_id

      t.string :name
      t.text :comment

      t.integer :in_price
      t.integer :distributor_price
      t.integer :retail_price

      t.timestamp :refined_at
      t.timestamp :expire_at

      t.timestamps

    end

    add_index :batches, [:name, :organization_id], unique: true
  end
end
