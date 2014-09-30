class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :organization_id
      t.string  :address
      t.string  :city
      t.string  :vat_number
      t.string  :name
      t.string  :zip
      t.string  :country
      t.string  :email
      t.string  :telephone
      t.boolean :reseller
      t.integer :primary_contact_id
      t.integer :payment_term

      t.timestamps
    end
  end
end
