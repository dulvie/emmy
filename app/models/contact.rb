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
  validates :email, uniqueness: true, if: :check_email
  validates :email, presence: true

  VALID_PARENT_TYPES = ['Customer', 'Supplier', 'Warehouse', 'ContactRelation', 'User']

  def check_email
    return false if organization.contacts.where('email=? and id <> ?', email, id).count == 0
    true
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
