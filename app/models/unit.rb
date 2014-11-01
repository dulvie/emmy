class Unit < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.string  :weight
  # t.string  :package_dimensions

  attr_accessible :name, :weight, :package_dimensions, :organization

  belongs_to :organization
  has_many :items

  validates :name, uniqueness: true, if: :inside_organization
  validates :name, presence: true

  def inside_organization
    if new_record?
      return true if Unit.where('organization_id = ? and name = ?', organization_id, name).size > 0
    else
      return true if Unit.where('id <> ? and organization_id = ? and name = ?', id, organization_id, name).size > 0
    end
    false
  end

  def can_delete?
    return false if items.size > 0
    true
  end
end
