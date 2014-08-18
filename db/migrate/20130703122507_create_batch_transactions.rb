class CreateBatchTransactions  < ActiveRecord::Migration
  def change
    create_table :batch_transactions do |t|
      t.integer :organisation_id
      t.string  :parent_type
      t.integer :parent_id
      t.integer :batch_id
      t.integer :warehouse_id
      t.integer :quantity

      t.timestamps
    end
  end
end
