class CreateDefaultCodeHeaders  < ActiveRecord::Migration
  def change
    create_table :default_code_headers do |t|
      t.string   :name
      t.string   :file_name
      t.string   :run_type
      t.string   :state
      t.integer  :accounting_plan_id
      t.integer  :organization_id

      t.timestamps
    end
  end
end
