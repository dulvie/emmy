class CreateProductions < ActiveRecord::Migration
  def change
    create_table :productions do |t|

      t.integer :user_id
      t.string :description
      t.integer :our_reference_id
      t.integer :warehouse_id      
      t.integer :product_id
      t.integer :quantity
      t.integer :cost_price
      t.integer :total_amount

      t.string :state
      t.timestamp :started_at
      t.timestamp :completed_at

      t.timestamps

    end
  end
end
