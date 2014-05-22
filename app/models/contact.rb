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
  # t.integer :user_id
  # t.integer :customer_id


  belongs_to :parent, polymorphic: true

  attr_accessible :email
end
