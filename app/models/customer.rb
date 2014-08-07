class Customer < ActiveRecord::Base
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

  has_many :contacts, as: :parent
  has_many :comments, as: :parent

  attr_accessible :name, :vat_number, :email, :telephone, :address, :zip, :city, :country, :reseller, :primary_contact_id, :payment_term

  validates :name, presence: true
  validates :name, :uniqueness => true
  validates :payment_term, presence: true

  def parent_name
    name
  end

  def can_delete?
    return false if Sale.where('customer_id = ?', self.id).size > 0
    true
  end

  def has_contacts?
    return true if contacts.size > 0
    return false
  end

  def primary_email
    "tbd@implement.now"
  end
end
