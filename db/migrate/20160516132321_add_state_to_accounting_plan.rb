class AddStateToAccountingPlan < ActiveRecord::Migration
  def change
    add_column :accounting_plans, :state, :string
  end
end
