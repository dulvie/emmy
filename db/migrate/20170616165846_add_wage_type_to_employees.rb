class AddWageTypeToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :wage_type, :string
  end
end
