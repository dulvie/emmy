class AddReferenceToSuppliers < ActiveRecord::Migration
  def change
    remove_column :suppliers, :bg_number
    add_column :suppliers, :reference, :string
    add_column :suppliers, :bankgiro, :string
    add_column :suppliers, :postgiro, :string
    add_column :suppliers, :plusgiro, :string
    add_column :suppliers, :supplier_type, :string
  end
end
