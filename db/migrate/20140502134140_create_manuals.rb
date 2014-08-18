class CreateManuals < ActiveRecord::Migration
  def change
    create_table :manuals do |t|
      t.integer :organisation_id
      t.integer :user_id

      t.timestamps
    end
  end
end
