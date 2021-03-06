class Customer < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.integer :vat_number
  # t.string :email
  # t.string :telephone
  # t.string  :address
  # t.string  :zip
  # t.string  :city
  # t.string  :country
  # t.boolean :reseller
  # t.integer :primary_contact_id
  # t.integer :payment_term

  belongs_to :organization

  has_many :contact_relations, as: :parent
  has_many :contacts, through: :contact_relations
  has_many :comments, as: :parent
  has_many :sales

  attr_accessible :name, :vat_number, :email, :telephone, :address, :zip, :city, :country, :reseller,
                  :primary_contact_id, :payment_term

  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :payment_term, presence: true

  def parent_name
    name
  end

  def can_delete?
    return false if Sale.where('customer_id = ?', id).size > 0
    true
  end

  def contacts?
    return true if contacts.size > 0
    false
  end

  def primary_email
    'tbd@implement.now'
  end
end
