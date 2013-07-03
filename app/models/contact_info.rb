class ContactInfo < ActiveRecord::Base
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

  # Contact info can either be tied to a user or a customer.
  belongs_to :user
  belongs_to :customer
  validates :user_id, presence: true,
            unless: Proc.new { |cinfo| cinfo.customer_id.present? } 
  validates :customer_id, presence: true,
            unless: Proc.new { |cinfo| cinfo.user_id.present? } 
end
