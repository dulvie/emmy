class AddWageTypeToEmployees < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :wage_type, :string
  end
end
