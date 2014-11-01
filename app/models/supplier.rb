class Supplier < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.string  :address
  # t.string  :zip
  # t.string  :city
  # t.string  :country
  # t.string  :bg_number
  # t.string  :vat_number
  # t.integer :primary_contact_id

  belongs_to :organization

  has_many :contact_relations, as: :parent
  has_many :contacts, through: :contact_relations

  has_many :comments, as: :parent
  has_many :purchases

  attr_accessible :name, :address, :zip, :city, :country, :bg_number, :vat_number, :primary_contact_id, :organization

  validates :name, presence: true
  validates :name, uniqueness: true, if: :inside_organization

  def inside_organization
    if new_record?
      return true if Supplier.where('organization_id = ? and name = ?', organization_id, name).size > 0
    else
      return true if Supplier.where('id <> ? and organization_id = ? and name = ?', id, organization_id, name).size > 0
    end
    false
  end

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
