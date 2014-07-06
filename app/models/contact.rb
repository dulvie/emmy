class Contact < ActiveRecord::Base
  # t.integer :parent_type
  # t.integer :parent_id
  # t.string :name
  # t.string :email
  # t.string :telephone
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.string :country
  # t.text :comment

  belongs_to :parent, polymorphic: true

  attr_accessible :email, :name, :telephone, :address, :zip, :city, :country, :comment

  validates :name, presence: true

  VALID_PARENT_TYPES = ['Customer', 'Supplier', 'Warehouse']

  # For ApplicationHelper#delete_button
  def can_delete?; true; end

  def parent_name
    parent.name
  end
end
