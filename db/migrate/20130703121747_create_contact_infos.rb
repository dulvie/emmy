class CreateContactInfos < ActiveRecord::Migration
  def change
    create_table :contact_infos do |t|
      t.string :name
      t.string :email
      t.string :telephone
      t.string :address
      t.string :zip
      t.string :city
      t.string :country
      t.text :comment
      t.integer :user_id
      t.integer :customer_id

      t.timestamps
    end
  end
end
