class Employee < ActiveRecord::Base
  # t.string   :name
  # t.integer  :birth_year
  # t.datetime :begin
  # t.datetime :end
  # t.decimal  :salary
  # t.decimal  :tax
  # t.string   :tax_table_column
  # t.integer  :tax_table_id
  # t.integer  :organization_id
  
  # t.timestamps

  before_update :set_tax
  before_create :set_tax

  attr_accessible :name, :begin, :ending, :salary, :tax, :birth_year,
    :tax_table_id, :tax_table_column

  validates :name, presence: true
  validates :birth_year, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}

  belongs_to :organization
  has_one :contact_relation, as: :parent
  has_one :contact, through: :contact_relation
  belongs_to :tax_table
  has_many :wages

  def set_tax
    self.tax = tax_table.calculate(salary, tax_table_column)
  end

  def parent_name
    self.name
  end

  def can_delete?
    return false if wages.size > 0
    true
  end
end
