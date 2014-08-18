class CreateShelves < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.integer :organisation_id
      t.integer :quantity, default: 0
      t.integer :warehouse_id
      t.integer :batch_id

      t.timestamps
    end
  end
end
