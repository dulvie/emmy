class RemoveAccountingPlanTransactions < ActiveRecord::Migration
  def change
    drop_table :accounting_plan_transactions
  end
end
