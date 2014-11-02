class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.integer :organization_id
      t.string  :name
      t.integer :primary_contact_id
      t.string  :address
      t.string  :zip
      t.string  :city

      t.timestamps
    end

    add_index :warehouses, [:name, :organization_id], unique: true
  end
end
