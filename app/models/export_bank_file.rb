class ExportBankFile < ActiveRecord::Base
  # t.datetime :export_date
  # t.datetime :from_date
  # t.datetime :to_date
  # t.string   :reference
  # t.string   :pay_account
  # t.string   :organization_number
  # t.string   :iban
  # t.integer  :organization_id
  # t.integer  :user_id
  # t.timestamps

  attr_accessible :export_date, :from_date, :to_date, :reference, :pay_account, :organization_number, :iban

  belongs_to :organization
  belongs_to :user
  has_many   :export_bank_file_rows, dependent: :delete_all
  # validates_attachment_content_type :upload, content_type: ['text/csv']

  TYPES = ['Fakturabetalning', 'Löneutbetalning']

  after_commit :create_bank_transaction

  def file_name
    return "#{organization.slug}_payment_bank_file_#{id}.csv" if self.reference == TYPES[0]
    return "#{organization.slug}_wage_bank_file_#{id}.csv" if self.reference == TYPES[1]
    return nil
  end

  def directory
    "tmp/downloads"
  end

  def file_exists?
    File.exists?directory+'/'+file_name
  end

  def file_filter
    return '/' + "#{organization.slug}_payment_bank_file*.*" if self.reference == TYPES[0]
    return '/' + "#{organization.slug}_wage_bank_file*.*" if self.reference == TYPES[1]
    return nil
  end

  def can_delete?
    true
  end

  def create_bank_transaction
    @bank_file_trans = BankFileTransaction.new
    @bank_file_trans.parent = self
    @bank_file_trans.execute = 'export'
    @bank_file_trans.complete = 'false'
    @bank_file_trans.directory = directory
    @bank_file_trans.file_name = file_name
    @bank_file_trans.user = user
    @bank_file_trans.organization = organization
    @bank_file_trans.save
  end
end
