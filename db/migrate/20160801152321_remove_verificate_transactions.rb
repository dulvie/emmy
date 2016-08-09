class RemoveVerificateTransactions < ActiveRecord::Migration
  def change
    drop_table :verificate_transactions
  end
end
