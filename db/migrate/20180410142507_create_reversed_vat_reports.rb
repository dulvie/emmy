class CreateReversedVatReports  < ActiveRecord::Migration
  def change
    create_table :reversed_vat_reports do |t|

      t.string   :vat_number
      t.integer  :goods
      t.integer  :services
      t.integer  :third_part
      t.string   :note
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :reversed_vat_id

      t.timestamps
    end
  end
end
