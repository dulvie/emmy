class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.integer :user_id
      t.integer :customer_id
      t.integer :warehouse_id
      t.string :contact_email
      t.string :contact_name
      t.integer :payment_term
      t.string :state
      t.string :goods_state
      t.string :money_state
      t.timestamp :approved_at
      t.timestamp :delivered_at
      t.timestamp :paid_at
      t.datetime :due_date

      t.timestamps
    end
  end
end
