class Employee < ActiveRecord::Base
  # t.string   :name
  # t.integer  :birth_year
  # t.datetime :begin
  # t.datetime :end
  # t.decimal  :salary
  # t.decimal  :tax
  # t.string   :tax_table_column
  # t.integer  :tax_table_id
  # t.string   :personal
  # t.string   :clearingnumber
  # t.string   :bank_account
  # t.integer  :organization_id

  # t.timestamps

  before_update :set_tax
  before_create :set_tax

  attr_accessible :name, :begin, :ending, :salary, :tax, :birth_year, :tax_table_id,
                  :tax_table_column, :personal, :clearingnumber, :bank_account

  validates :name, presence: true
  validates :birth_year, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates_format_of :personal, with: /\A[0-9]{2}[0-1]{1}[0-9]{1}[0-3]{1}[0-9]{1}-[0-9]{4}\z/

  belongs_to :organization
  has_one :contact_relation, as: :parent
  has_one :contact, through: :contact_relation
  belongs_to :tax_table
  has_many :wages

  def set_tax
    self.tax = tax_table.calculate(salary, tax_table_column)
  end

  def age
    year = DateTime.now.strftime('%Y').to_i
    (year - birth_year)
  end

  def parent_name
    name
  end

  def can_delete?
    return false if wages.size > 0
    true
  end
end
