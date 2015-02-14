class AddCodeToWageReports < ActiveRecord::Migration
  def change
    add_column :wage_reports, :code, :integer
    add_column :wage_reports, :text, :string
  end
end
