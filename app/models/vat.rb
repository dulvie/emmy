class Vat < ActiveRecord::Base
  # t.integer :organization_id
  # t.string  :name
  # t.integer :vat_percent

  belongs_to :organization
  has_many :items

  attr_accessible :name, :vat_percent

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :vat_percent, presence: true

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

  def to_s
    name
  end
end
