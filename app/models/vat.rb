class Vat < ActiveRecord::Base
  # t.integer :organisation_id
  # t.string  :name
  # t.integer :vat_percent

  attr_accessible :name, :vat_percent, :organisation

  belongs_to :organisation
  has_many :items

  validates :name, uniqueness: true
  validates :name, presence: true
  validates :vat_percent, presence: true

  def can_delete?
    true
  end

  def add_factor
    vat_percent.to_d / 100
  end

  def sub_factor
    vat_percent.to_d / (100 + vat_percent.to_d)
  end

  def vat_add(amount)
    amount * add_factor
  end

  def vat_sub(amount)
    amount * sub_factor
  end
end
