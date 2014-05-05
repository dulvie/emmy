class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :address
      t.string :city
      t.integer :orgnr
      t.string :name
      t.string :zip
      t.timestamps
    end
  end
end
