class CreateExportBankFileRows < ActiveRecord::Migration
  def change
    create_table :export_bank_file_rows do |t|
      t.datetime :posting_date
      t.decimal  :amount, precision: 9, scale: 2
      t.string   :bank_account
      t.string   :ocr
      t.string   :name
      t.string   :reference
      t.datetime :bank_date
      t.string   :currency_paid
      t.string   :currency_debit
      t.integer  :organization_id
      t.integer  :export_bank_file_id
      t.timestamps
    end
  end
end
