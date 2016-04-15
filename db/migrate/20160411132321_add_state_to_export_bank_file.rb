class AddStateToExportBankFile < ActiveRecord::Migration
  def change
    add_column :export_bank_files, :state, :string
    add_attachment :export_bank_files, :download
  end
end
