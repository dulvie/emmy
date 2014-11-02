class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.integer :organization_id
      t.string  :name
      t.string  :address
      t.string  :zip
      t.string  :city
      t.string  :country
      t.string  :bg_number
      t.string  :vat_number
      t.integer :primary_contact_id
      t.timestamps
    end

    add_index :suppliers, [:name, :organization_id], unique: true
  end
end
