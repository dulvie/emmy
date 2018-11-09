class ExportBankFileRow < ActiveRecord::Base
  # t.datetime :posting_date
  # t.decimal  :amount, precision: 9, scale: 2
  # t.string   :bankgiro
  # t.string   :plusgiro
  # t.string   :ocr
  # t.string   :name
  # t.string   :reference
  # t.datetime :bank_date
  # t.string   :currency_paid
  # t.string   :currency_debit
  # t.integer  :organization_id
  # t.integer  :export_bank_file_id
  # t.timestamps

  #attr_accessible :posting_date, :amount, :bankgiro, :plusgiro, :ocr, :name, :reference,
  #                :bank_date

  belongs_to :organization
  belongs_to :export_bank_file

  def can_delete?
    true
  end
end
