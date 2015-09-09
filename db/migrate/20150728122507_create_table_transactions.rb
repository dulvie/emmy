class CreateTableTransactions  < ActiveRecord::Migration
  def change
    create_table :table_transactions do |t|
      t.string   :directory
      t.string   :file_name
      t.string   :execute
      t.integer  :year
      t.string   :table
      t.boolean  :complete
      t.integer  :organization_id
      t.integer  :user_id

      t.timestamps
    end
  end
end
