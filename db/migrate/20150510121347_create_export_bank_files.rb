class CreateExportBankFiles < ActiveRecord::Migration
  def change
    create_table :export_bank_files do |t|
      t.datetime :export_date
      t.datetime :from_date
      t.datetime :to_date
      t.string   :reference
      t.string   :organization_number
      t.string   :pay_account
      t.string   :iban
      t.integer  :organization_id
      t.timestamps
    end
  end
end
