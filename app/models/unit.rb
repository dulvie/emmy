class Unit < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.string  :weight
  # t.string  :package_dimensions

  belongs_to :organization
  has_many :items

  attr_accessible :name, :weight, :package_dimensions

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def can_delete?
    return false if items.count > 0
    true
  end
end
