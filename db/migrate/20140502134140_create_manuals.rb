class CreateManuals < ActiveRecord::Migration
  def change
    create_table :manuals do |t|
      t.integer :user_id
      t.string :state

      t.timestamps
    end
  end
end
