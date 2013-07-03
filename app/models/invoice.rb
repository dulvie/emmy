class Invoice < ActiveRecord::Base
  # t.string :customer_contact
  # t.string :user_contact
  # t.integer :current_state
  # t.timestamp :sent_at
  # t.integer :total
  # t.integer :total_excluding_vat
  # t.integer :total_including_vat
  # t.timestamp :paid_date
  # t.integer :user_id
  # t.integer :customer_id

  belongs_to :user
  belongs_to :customer
  has_many :invoice_items
end
