class Employee < ActiveRecord::Base
  # t.string   :name
  # t.integer  :birth_year
  # t.datetime :begin
  # t.datetime :end
  # t.decimal  :salary
  # t.decimal  :tax
  # t.integer  :organization_id
  
  # t.timestamps

  attr_accessible :name, :begin, :ending, :salary, :tax, :birth_year

  validates :name, presence: true
  validates :birth_year, presence: true

  belongs_to :organization
  has_one :contact_relation, as: :parent
  has_one :contact, through: :contact_relation
  has_many :wages

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def parent_name
    self.name
  end

  def can_delete?
    return false if wages.size > 0
    true
  end
end
