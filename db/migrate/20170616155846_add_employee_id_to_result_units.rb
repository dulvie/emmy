class AddEmployeeIdToResultUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :result_units, :employee_id, :integer
  end
end
