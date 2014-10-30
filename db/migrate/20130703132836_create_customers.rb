class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :organization_id, null: false
      t.string  :address
      t.string  :city
      t.string  :vat_number
      t.string  :name, null: false
      t.string  :zip
      t.string  :country
      t.string  :email
      t.string  :telephone
      t.boolean :reseller
      t.integer :primary_contact_id
      t.integer :payment_term

      t.timestamps
    end

    add_index :organization_scope, [:name, :organization_id], unique: true
  end
end
