class InvoiceItem < ActiveRecord::Base
  # t.string :name
  # t.integer :quantity
  # t.integer :vat
  # t.integer :price
  # t.integer :invoice_id
  # t.integer :product_id
  # t.integer :slot_change_id

  belongs_to :product
  belongs_to :invoice
  belongs_to :slot_change

  validates :invoice_id, presence: true
  validates :product_id, presence: true
end
