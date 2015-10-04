class DefaultCode < ActiveRecord::Base
  # t.integer  :code
  # t.string   :text
  # t.integer  :organization_id

  attr_accessible :code, :text

  belongs_to :organization
  has_many   :accounts

  validates :code, presence: true, uniqueness: {scope: :organization_id}
  validates :text, presence: true

  DIRECTORY = 'files/codes/'
  FILES = 'Default*.csv'

  def self.validate_file(import_file)
    file_importer = FileImporter.new(DIRECTORY, nil, nil)
    files = file_importer.files(FILES)
    files.include?(import_file)
  end

  def name
    text
  end

  def can_delete?
    return false if accounts.size > 0
    true
  end
end
