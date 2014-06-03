class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
    
      t.integer :user_id
      t.string :description
      t.integer :our_reference_id
      t.integer :to_warehouse_id
      t.string :state
      t.timestamp :started_at
      t.timestamp :completed_at
      
      t.timestamps
    end
  end
end
