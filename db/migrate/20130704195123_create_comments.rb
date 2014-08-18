class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :organisation_id
      t.text :body
      t.string :parent_type
      t.integer :parent_id
      t.integer :user_id

      t.timestamps
    end
  end
end
