class Warehouse < ActiveRecord::Base
  # t.integer :organization_id
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.integer :primary_contact_id

  belongs_to :organization
  has_many :shelves, dependent: :destroy
  has_many :contact_relations, as: :parent
  has_many :contacts, through: :contact_relations
  has_many :comments, as: :parent
  has_many :batch_transactions
  has_many :manuals, through: :batch_transactions, source: :parent, source_type: 'Manual'
  has_many :sales

  attr_accessible :name, :address, :zip, :city, :primary_contact_id

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def batches_in_stock
    @batches_in_stock ||= shelves.includes(:batch).collect { |s| s.batch }
  end

  def can_delete?
    return false if  batches_in_stock.size > 0
    true
  end

  def parent_name
    name
  end

  def contacts?
    return true if contacts.size > 0
    false
  end
end
