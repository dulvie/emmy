class AddInvoiceTextToSale < ActiveRecord::Migration[7.0]
  def change
    add_column :sales, :invoice_text, :text
  end
end
