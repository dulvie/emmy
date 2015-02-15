class AddDefaultCodeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :default_code_id, :integer
  end
end
