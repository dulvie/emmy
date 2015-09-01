class CreateBalanceTransactions  < ActiveRecord::Migration
  def change
    create_table :balance_transactions do |t|
      t.string   :parent_type
      t.integer  :parent_id
      t.string   :execute
      t.boolean  :complete
      t.integer  :accounting_period_id
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
