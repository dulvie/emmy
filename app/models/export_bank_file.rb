class ExportBankFile < ActiveRecord::Base
  # t.string   :name
  # t.datetime :export_date
  # t.datetime :from_date
  # t.datetime :to_date
  # t.string   :reference
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :export_date, :from_date, :to_date, :reference

  belongs_to :organization
  # validates_attachment_content_type :upload, content_type: ['text/csv']

  def can_delete?
    true
  end
end
