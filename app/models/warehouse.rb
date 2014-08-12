class Warehouse < ActiveRecord::Base
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.integer :primary_contact_id

  has_many :shelves, :dependent => :destroy
  has_many :contacts, as: :parent
  has_many :comments, as: :parent
  has_many :manuals
  has_many :batch_transactions

  attr_accessible :name, :address, :zip, :city, :primary_contact_id

  validates :name, :uniqueness => true
  validates :name, :presence => true

  def batches_in_stock
    @batches_in_stock ||= shelves.includes(:batch).collect{|s| s.batch}
  end

  def can_delete?
    return false if  batches_in_stock.size > 0
    true
  end

  def parent_name
    name
  end

  def has_contacts?
    return true if contacts.size > 0
    return false
  end

end
