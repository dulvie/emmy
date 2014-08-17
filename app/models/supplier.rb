class Supplier < ActiveRecord::Base
  # t.string  :name
  # t.string  :address
  # t.string  :zip
  # t.string  :city
  # t.string  :country
  # t.string  :bg_number
  # t.string  :vat_number
  # t.integer :primary_contact_id

  has_many :contacts, as: :parent
  has_many :comments, as: :parent
  has_many :purchases

  attr_accessible :name, :address, :zip, :city, :country, :bg_number, :vat_number, :primary_contact_id

  validates :name, presence: true
  validates :name, :uniqueness => true

  def can_delete?
    return false if Purchase.where("supplier_id = ?", self.id).size > 0
    true
  end

  def has_contacts?
    return true if contacts.size > 0
    return false
  end

  def parent_name
    name
  end
end
