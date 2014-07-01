class Supplier < ActiveRecord::Base
  # t.string  :name
  # t.string  :address
  # t.string  :zip
  # t.string  :city
  # t.string  :bg_number
  # t.string  :vat_number

  has_many :contacts, as: :parent
  has_many :comments, as: :parent

  attr_accessible :name, :address, :zip, :city, :bg_number, :vat_number

  validates :name, presence: true

  def can_delete?
    return false if Purchase.where("supplier_id = ?", self.id).size > 0
    true
  end

  def parent_name
    name
  end
end
