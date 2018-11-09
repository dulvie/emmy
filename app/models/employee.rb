class Employee < ActiveRecord::Base
  # t.string   :name
  # t.integer  :birth_year
  # t.datetime :begin
  # t.datetime :end
  # t.string   :wage_type
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
  before_save   :set_salary

  #attr_accessible :name, :begin, :ending, :wage_type, :salary, :tax, :birth_year, :tax_table_id,
  #                :tax_table_column, :personal, :clearingnumber, :bank_account

  WAGE_TYPES = ['Fixed', 'Invoiced']

  # payroll_tax percentage to be reported in box 55, 59 and 61
  # see https://www.skatteverket.se/foretagochorganisationer/arbetsgivare/arbetsgivaravgifterochskatteavdrag/arbetsgivaravgifter.4.233f91f71260075abe8800020817.html
  PAYROLL_TAX_55 = '0.3142'
  PAYROLL_TAX_59 = '0.1636'
  PAYROLL_TAX_61 = '0.0615'

  validates :name, presence: true
  validates :birth_year, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates_format_of :personal, with: /\A[0-9]{2}[0-1]{1}[0-9]{1}[0-3]{1}[0-9]{1}-[0-9]{4}\z/
  validates :wage_type, inclusion: { in: WAGE_TYPES }

  belongs_to :organization
  has_one :contact_relation, as: :parent
  has_one :contact, through: :contact_relation
  belongs_to :tax_table
  has_many :wages
  has_one :result_unit

  def full_name
    return contact.name if !contact.nil?
    name
  end

  def set_tax
    return 0 if salary.nil?
    self.tax = tax_table.calculate(salary, tax_table_column)
  end

  def set_salary
    self.salary = 0 if salary.nil?
  end

  def age
    year = DateTime.now.strftime('%Y').to_i
    (year - birth_year)
  end

  def payroll_percent
    case age
      when 0..65
        percentage = BigDecimal.new(PAYROLL_TAX_55)
      when 65..78
        percentage = BigDecimal.new(PAYROLL_TAX_59)
      when 78..99
        percentage = BigDecimal.new(PAYROLL_TAX_61)
      else
        percentage = 1
    end
  end

  def payroll_percent_old
    case age
      when 0..26
        percentage = BigDecimal.new('0.1549')
      when 26..65
        percentage = BigDecimal.new('0.3142')
      when 65..99
        percentage = BigDecimal.new('0.1021')
      else
        percentage = 1
    end
  end

  def parent_name
    name
  end

  def can_delete?
    return false if wages.size > 0
    true
  end
end
