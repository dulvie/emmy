class TaxTable < ActiveRecord::Base
  # t.string   :name
  # t.integer  :year
  # t.integer  :organization_id

  # t.timestamps


  attr_accessible :name, :year

  belongs_to :organization
  has_many :tax_table_rows, dependent: :destroy
  has_many :employees

  TABLES = *(29..40)
  COLUMNS = ['1', '2','3','4','5','6']

  validates :year, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}

  DIRECTORY = 'files/codes/'
  FILES = 'allm*.csv'

  def self.validate_file(import_file)
    file_importer = FileImporter.new(DIRECTORY, nil, nil)
    files = file_importer.files(FILES)
    files.include?(import_file)
  end

  def calculate(wage, column)
    row = tax_table_rows.where('from_wage <= ? AND to_wage >= ?', wage, wage).first
    return row.tax(wage, column)
  end

  def can_delete?
    return false if employees.size > 0
    true
  end
end
