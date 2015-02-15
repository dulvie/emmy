class CreateDefaultCodes < ActiveRecord::Migration
  def change
    create_table :default_codes do |t|
      t.integer  :code
      t.string   :text
      t.integer  :organization_id
      t.timestamps
    end
  end
end
