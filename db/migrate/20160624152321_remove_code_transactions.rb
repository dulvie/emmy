class RemoveCodeTransactions < ActiveRecord::Migration
  def change
    drop_table :code_transactions
  end
end
