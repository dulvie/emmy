class CreateCodeTransactions  < ActiveRecord::Migration
  def change
    create_table :code_transactions do |t|

      t.string   :directory
      t.string   :file
      t.string   :code
      t.string   :run_type
      t.integer  :accounting_plan_id
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
