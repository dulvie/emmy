class AddStateToTaxTables < ActiveRecord::Migration
  def change
    add_column :tax_tables, :file_name, :string
    add_column :tax_tables, :table_name, :string
    add_column :tax_tables, :state, :string
  end
end
