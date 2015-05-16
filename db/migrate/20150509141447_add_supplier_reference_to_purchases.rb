class AddSupplierReferenceToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :supplier_reference, :string
  end
end
