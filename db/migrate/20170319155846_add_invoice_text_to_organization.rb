class AddInvoiceTextToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :invoice_text, :string
  end
end
