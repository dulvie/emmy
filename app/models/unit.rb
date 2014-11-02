class Unit < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.string  :weight
  # t.string  :package_dimensions

  attr_accessible :name, :weight, :package_dimensions, :organization

  belongs_to :organization
  has_many :items

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def can_delete?
    return false if items.size > 0
    true
  end
end
