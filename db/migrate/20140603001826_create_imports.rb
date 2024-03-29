class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.integer :organization_id
      t.integer :user_id
      t.string :description
      t.integer :our_reference_id
      t.integer :to_warehouse_id
      t.integer :batch_id
      t.integer :quantity
      t.integer :amount
      t.integer :cost_price

      t.integer :importing_id
      t.integer :shipping_id
      t.integer :customs_id

      t.string :state
      t.timestamp :started_at
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
