class CreateAccountingPlanTransactions  < ActiveRecord::Migration
  def change
    create_table :accounting_plan_transactions do |t|

      t.datetime :posting_date
      t.string   :directory
      t.string   :file
      t.string   :execute
      t.integer  :accounting_plan_id
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
