class Vat < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.integer :vat_percent

  attr_accessible :name, :vat_percent, :organization, :organization_id

  belongs_to :organization
  has_many :items

  validates :name, uniqueness: true, if: :inside_organization
  validates :name, presence: true
  validates :vat_percent, presence: true

  def inside_organization
    if new_record?
      return true if Vat.where('organization_id = ? and name = ?', organization_id, name).size > 0
    else
      return true if Vat.where('id <> ? and organization_id = ? and name = ?', id, organization_id, name).size > 0
    end
    false
  end

  def can_delete?
    true
  end

  def add_factor
    return 0 if vat_percent.blank?
    vat_percent.to_d / 100
  end

  def sub_factor
    return 0 if vat_percent.blank?
    vat_percent.to_d / (100 + vat_percent.to_d)
  end

  def vat_add(amount)
    amount * add_factor
  end

  def vat_sub(amount)
    amount * sub_factor
  end
end
