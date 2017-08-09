class Wage < ActiveRecord::Base
  # t.datetime :wage_from
  # t.datetime :wage_to
  # t.datetime :payment_date
  # t.decimal  :salery
  # t.decimal  :addition
  # t.decimal  :discount
  # t.decimal  :tax
  # t.decimal  :payroll_tax
  # t.decimal  :amount
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :wage_period_id
  # t.integer  :employee_id

  attr_accessible :employee_id, :wage_from, :wage_to, :payment_date, :salary, :addition, :discount,
                  :tax, :payroll_tax, :amount, :wage_period_id, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :wage_period
  belongs_to :employee
  has_one :verificate
  has_one :document, as: :parent, dependent: :delete

  before_save :set_payroll_tax
  before_save :set_tax
  before_save :set_amount

  validates :accounting_period, presence: true
  validates :employee, presence: true
  validates :wage_from, presence: true
  validates :wage_to, presence: true
  validates :payment_date, presence: true

  def set_document(name, pdf_string)
    d = build_document
    logger.info 'Wage#set_document: will try to write to temp file'
    tempfile = Tempfile.new([name, '.pdf'], Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write pdf_string
    logger.info "Wage#set_document: will now set d.upload = #{tempfile.path} or rather, content of that file"
    d.upload = tempfile
    logger.info 'Wage#set_document: SAVING!'
    tempfile.close
    tempfile.unlink
    d.save!
  end

  def gross
    salary + addition - discount
  end

  def set_payroll_tax
    self.payroll_tax = (gross * employee.payroll_percent).round
  end

  def set_tax
    self.tax = employee.tax_table.calculate(gross, employee.tax_table_column)
  end

  def set_amount
    self.amount = gross - tax
  end

  def has_document?
    return false if document.nil?
    return true
  end

  def can_delete?
    return true if wage_period.can_calculate_wage?
    false
  end
end
