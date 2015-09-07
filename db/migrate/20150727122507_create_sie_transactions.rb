class CreateSieTransactions  < ActiveRecord::Migration
  def change
    create_table :sie_transactions do |t|
      t.string   :directory
      t.string   :file_name
      t.string   :execute
      t.string   :sie_type
      t.boolean  :complete
      t.integer  :accounting_period_id
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
