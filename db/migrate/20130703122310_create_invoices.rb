class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :customer_contact
      t.string :user_contact
      t.integer :current_state
      t.timestamp :sent_at
      t.integer :total
      t.integer :total_excluding_vat
      t.integer :total_including_vat
      t.timestamp :paid_date
      t.integer :user_id
      t.integer :customer_id

      t.timestamps
    end
  end
end
