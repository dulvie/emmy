class AddInvoiceTextToSale < ActiveRecord::Migration
  def change
    add_column :sales, :invoice_text, :text
  end
end
