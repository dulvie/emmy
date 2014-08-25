class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.integer :organisation_id
      t.integer :parent_id
      t.string :parent_type
      t.integer :user_id
      t.integer :supplier_id
      t.string :contact_email
      t.string :contact_name
      t.string :contact_name
      t.string :description
      t.integer :our_reference_id
      t.integer :to_warehouse_id

      t.string :state
      t.string :goods_state
      t.string :money_state
       
      t.timestamp :completed_at
      t.timestamp :ordered_at
      t.timestamp :received_at
      t.timestamp :paid_at
      t.datetime :due_date

      t.timestamps
    end
  end

end
