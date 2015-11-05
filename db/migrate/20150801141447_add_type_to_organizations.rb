class AddTypeToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :organization_number, :string
    add_column :organizations, :organization_type, :string
  end
end
