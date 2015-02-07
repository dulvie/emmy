class AddFileNameToAccountingPlans < ActiveRecord::Migration
  def change
    add_column :accounting_plans, :file_name, :string
  end
end
