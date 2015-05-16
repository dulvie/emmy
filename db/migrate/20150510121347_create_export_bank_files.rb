class CreateExportBankFiles < ActiveRecord::Migration
  def change
    create_table :export_bank_files do |t|
      t.datetime :export_date
      t.datetime :from_date
      t.datetime :to_date
      t.string   :reference
      t.integer  :organization_id
      t.timestamps
    end
  end
end
