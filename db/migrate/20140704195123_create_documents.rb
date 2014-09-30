class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer    :organization_id
      t.string     :parent_type
      t.integer    :parent_id
      t.integer    :user_id
      t.string     :name
      t.attachment :upload

      t.timestamps
    end
  end
end
