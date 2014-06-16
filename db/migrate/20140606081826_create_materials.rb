class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|

      t.integer :production_id
      t.integer :product_id
      t.integer :quantity

      t.string :state
      t.timestamp :started_at
      t.timestamp :completed_at

      t.timestamps

    end
  end
end
