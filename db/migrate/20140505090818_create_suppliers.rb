class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :address
      t.string :zip
      t.string :city
      t.string :country
      t.string :bg_number
      t.string :vat_number
      t.timestamps
    end
  end
end
