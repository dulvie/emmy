class CreateVerificateTransactions  < ActiveRecord::Migration
  def change
    create_table :verificate_transactions do |t|
      t.integer  :organization_id
      t.integer  :user_id
      t.string   :parent_type
      t.integer  :parent_id
      t.datetime :posting_date
      t.string   :verificate_type

      t.timestamps
    end
  end
end
