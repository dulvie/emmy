class ExportBankFile < ActiveRecord::Base
  # t.datetime :export_date
  # t.datetime :from_date
  # t.datetime :to_date
  # t.string   :reference
  # t.string   :pay_account
  # t.string   :organization_number
  # t.string   :iban
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :export_date, :from_date, :to_date, :reference, :pay_account, :organization_number, :iban

  belongs_to :organization
  has_many   :export_bank_file_rows, dependent: :delete_all
  # validates_attachment_content_type :upload, content_type: ['text/csv']

  TYPES = ['Fakturabetalning', 'Löneutbetalning']

  def can_delete?
    true
  end
end
