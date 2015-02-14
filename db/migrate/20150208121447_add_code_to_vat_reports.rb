class AddCodeToVatReports < ActiveRecord::Migration
  def change
    add_column :vat_reports, :code, :integer
    add_column :vat_reports, :text, :string
  end
end
