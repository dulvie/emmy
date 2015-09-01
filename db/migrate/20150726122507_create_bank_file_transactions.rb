class CreateBankFileTransactions  < ActiveRecord::Migration
  def change
    create_table :bank_file_transactions do |t|
      t.string   :directory
      t.string   :file_name
      t.string   :execute
      t.boolean  :complete
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
