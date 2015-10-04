class AccountingPlan < ActiveRecord::Base
  # t.string   :name
  # t.string   :description
  # t.string   :file_name
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :description, :file_name

  belongs_to :organization
  has_many :accounting_classes, dependent: :destroy
  has_many :accounting_groups, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :accounting_periods

  validates :name, presence: true, uniqueness: {scope: :organization_id}

 DIRECTORY = 'files/accounting_plans/'
 FILES = '*.csv'

  def self.validate_file(import_file)
    file_importer = FileImporter.new(DIRECTORY, nil, nil)
    files = file_importer.files(FILES)
    files.include?(import_file)
  end

  def disable_accounts?
    return true if file_name && file_name.include?('Normal')
    false
  end

  def can_delete?
    return false if accounting_periods.size > 0
    true
  end
end
