class CreateCostitems < ActiveRecord::Migration
  def change
    create_table :costitems do |t|

      t.string :parent_type
      t.integer :parent_id

      t.string :description
      t.integer :supplier_id
      t.string :contact_email
      t.string :contact_name
      t.integer :product_id
      t.integer :quantity
      t.integer :price
      t.integer :total_amount
      t.integer :vat_amount

      t.string :state
      t.string :goods_state
      t.string :money_state

      t.timestamp :ordered_at
      t.timestamp :completed_at
      t.timestamp :received_at
      t.timestamp :paid_at
      t.datetime :due_date

      t.timestamps

    end
  end
end
