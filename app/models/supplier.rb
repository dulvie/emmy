class Supplier < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.string  :address
  # t.string  :zip
  # t.string  :city
  # t.string  :country
  # t.string  :bankgiro
  # t.string  :postgiro
  # t.string  :plusgiro
  # t.string  :reference
  # t.string  :supplier_type
  # t.string  :vat_number
  # t.integer :primary_contact_id

  belongs_to :organization

  has_many :contact_relations, as: :parent
  has_many :contacts, through: :contact_relations

  has_many :comments, as: :parent
  has_many :purchases

  #attr_accessible :name, :address, :zip, :city, :country, :vat_number,
  #  :primary_contact_id, :bankgiro, :postgiro, :plusgiro, :reference,
  #  :supplier_type

  TYPES = ['RSV', ' ']
  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def can_delete?
    return false if Purchase.where('supplier_id = ?', id).size > 0
    true
  end

  def contacts?
    return true if contacts.size > 0
    false
  end

  def parent_name
    name
  end
end
