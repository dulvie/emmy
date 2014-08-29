class Contact < ActiveRecord::Base
  # t.integer :organisation_id
  # t.string :name
  # t.string :email
  # t.string :telephone
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.string :country
  # t.text :comment

  belongs_to :organisation
  has_many :contact_relations

  attr_accessible :email, :name, :telephone, :address, :zip, :city, :country, :comment, :organisation

  validates :name, presence: true
  validates :email, :uniqueness => true
  validates :email, presence: true

  VALID_PARENT_TYPES = ['Customer', 'Supplier', 'Warehouse', 'ContactRelation', 'User']

  # For ApplicationHelper#delete_button
  def can_delete?
    return false if ContactRelation.where("contact_id=?", self.id).count > 0
    return true
  end

  def parent_name
    parent.name
  end
end
