class CreateContactRelations < ActiveRecord::Migration
  def change
    create_table :contact_relations do |t|
      t.integer :organisation_id
      t.integer :warehouse_id
      t.string  :parent_type
      t.integer :parent_id
      t.integer :contact_id

      t.timestamps
    end
  end
end
