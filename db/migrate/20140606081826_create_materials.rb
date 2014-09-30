class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.integer :organization_id
      t.integer :production_id
      t.integer :batch_id
      t.integer :quantity

      t.string :state
      t.timestamp :started_at
      t.timestamp :completed_at

      t.timestamps

    end
  end
end
