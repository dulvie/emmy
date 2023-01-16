class AddInvoiceTextToOrganization < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :invoice_text, :string
  end
end
