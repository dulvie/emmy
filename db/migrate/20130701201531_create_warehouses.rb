class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string :name
      t.string :address
      t.string :zip
      t.string :city

      t.timestamps
    end
  end
end
