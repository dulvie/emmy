class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string  :parent_type
      t.integer :parent_id

      t.string  :name
      t.string  :email
      t.string  :telephone
      t.string  :address
      t.string  :zip
      t.string  :city
      t.string  :country
      t.text    :comment

      t.timestamps
    end
  end
end
