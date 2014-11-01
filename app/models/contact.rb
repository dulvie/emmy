class Contact < ActiveRecord::Base
  # t.integer :organization_id
  # t.string :name
  # t.string :email
  # t.string :telephone
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.string :country
  # t.text :comment

  belongs_to :organization
  has_many :contact_relations

  attr_accessible :email, :name, :telephone, :address, :zip, :city, :country, :comment, :organization

  validates :name, presence: true
  validates :email, uniqueness: true, if: :inside_organization
  validates :email, presence: true

  VALID_PARENT_TYPES = ['Customer', 'Supplier', 'Warehouse', 'ContactRelation', 'User']

  def inside_organization
    if new_record?
      return true if Contact.where('organization_id = ? and email = ?', organization_id, email).size > 0
    else
      return true if Contact.where('id <> ? and organization_id = ? and email = ?', id, organization_id, email).size > 0
    end
    false
  end

  def user_parent?
    return true if contact_relations.where("parent_type = 'User'").count > 0
    false
  end

  # For ApplicationHelper#delete_button
  def can_delete?
    return false if ContactRelation.where('contact_id=?', id).count > 0
    true
  end

  def parent_name
    parent.name
  end
end
