class AddStateToImportBankFile < ActiveRecord::Migration
  def change
    add_column :import_bank_files, :state, :string
    add_attachment :import_bank_files, :upload
  end
end
