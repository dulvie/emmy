class CreateSieExports  < ActiveRecord::Migration
  def change
    create_table :sie_exports do |t|
      t.datetime :export_date
      t.string   :sie_type
      t.string   :state
      t.attachment :download
      t.integer  :accounting_period_id
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
