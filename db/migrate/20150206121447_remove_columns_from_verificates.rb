class RemoveColumnsFromVerificates < ActiveRecord::Migration
  def change
    remove_column :verificates, :vat_period_id
    remove_column :verificates, :wage_period_wage_id
    remove_column :verificates, :wage_period_report_id
    remove_column :verificates, :import_bank_file_row_id
  end
end
