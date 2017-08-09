class AddEmployeeIdToResultUnits < ActiveRecord::Migration
  def change
    add_column :result_units, :employee_id, :integer
  end
end
