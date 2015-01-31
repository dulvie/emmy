class ImportBankFile < ActiveRecord::Base
  # t.string   :name
  # t.datetime :import_date
  # t.datetime :from_date
  # t.datetime :to_date
  # t.string   :reference
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :import_date, :from_date, :to_date, :reference

  has_attached_file :upload
  belongs_to :organization
  has_many   :import_bank_file_rows, dependent: :destroy
  # validates_attachment_content_type :upload, content_type: ['text/csv']

  def name
    'Nordea'
  end

  def can_delete?
    true
  end
end
