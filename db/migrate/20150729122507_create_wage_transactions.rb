class CreateWageTransactions  < ActiveRecord::Migration
  def change
    create_table :wage_transactions do |t|
      t.string   :execute
      t.boolean  :complete
      t.integer  :wage_period_id
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
