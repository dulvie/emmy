class RemoveBalanceTransactions < ActiveRecord::Migration
  def change
    drop_table :balance_transactions
  end
end
