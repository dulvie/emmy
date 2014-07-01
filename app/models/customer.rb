class Customer < ActiveRecord::Base
  # t.string  :name
  # t.integer :vat_number
  # t.string  :address
  # t.string  :zip
  # t.string  :city
  # t.boolean :reseller

  has_many :contacts, as: :parent
  has_many :comments, as: :parent

  attr_accessible :name, :vat_number, :address, :zip, :city, :reseller

  validates :name, presence: true

  def parent_name
    name
  end

  def can_delete?
    return false if Sale.where('customer_id = ?', self.id).size > 0
    true
  end

  def primary_email
    "tbd@implement.now"
  end
end
