class AddPersonalToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :personal, :string
  end
end
