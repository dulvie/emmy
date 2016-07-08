class RemoveWageTransactions < ActiveRecord::Migration
  def change
    drop_table :wage_transactions
  end
end
