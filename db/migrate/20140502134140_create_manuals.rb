class CreateManuals < ActiveRecord::Migration
  def change
    create_table :manuals do |t|
      t.integer :organization_id
      t.integer :user_id

      t.timestamps
    end
  end
end
