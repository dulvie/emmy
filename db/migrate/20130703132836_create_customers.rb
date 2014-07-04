class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string  :address
      t.string  :city
      t.string  :vat_number
      t.string  :name
      t.string  :zip
      t.string  :country
      t.boolean :reseller
      t.timestamps
    end
  end
end
