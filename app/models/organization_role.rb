class OrganizationRole < ActiveRecord::Base
  # t.string  :name, null: false
  # t.integer :user_id, null: false
  # t.integer :organization_id, null: false
  # add_index :organization_roles,
  #           [:name, :user_id, :organization_id],
  #           unique: true,
  #           name: :organization_roles_index

  belongs_to :user
  belongs_to :organization

  attr_accessible :name, :user_id, :organization_id
end
