class CreateAccountingPlans < ActiveRecord::Migration
  def change
    create_table :accounting_plans do |t|
      t.string   :name
      t.string   :description
      t.string   :file_name
      t.integer  :organization_id
      t.timestamps
    end
  end
end
