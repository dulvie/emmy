# encoding: utf-8
class Organization < ActiveRecord::Base
  # t.string :slug, null: false, unique: true
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.string :organization_type
  # t.string :organization_number
  # t.string :vat_number
  # t.string :bankgiro
  # t.string :postgiro
  # t.string :plusgiro
  # t.string :swift
  # t.string :iban
  # t.timestamps

  TYPES = ['Aktiebolag', 'Ekonomisk förening', 'Idell förening', 'Handelsbolag', 'Enskild firma']
  BANK_FIELDS = %w(vat_number bankgiro plusgiro postgiro iban swift)

  attr_accessible :email, :name, :address, :zip, :organization_type, :organization_number,
                  :vat_number, :bankgiro, :postgiro, :plusgiro, :city, :swift, :iban

  has_many :organization_roles
  has_many :users, through: :organization_roles

  [:accounting_classes, :accounting_groups, :accounting_periods, :accounting_plans, :accounts,
   :balance_transactions, :bank_file_transactions, :batches, :batch_transactions, :closing_balances,
   :code_transactions, :comments, :contact_relations, :contacts, :conversions, :customers, :default_codes,
   :documents, :employees, :export_bank_files, :export_bank_file_rows, :imports, :ink_codes, :import_bank_files,
   :import_bank_file_rows, :inventories, :items, :ledgers, :ledger_accounts, :ledger_transactions,
   :manuals, :materials, :ne_codes, :opening_balances, :opening_balance_items, :productions, :purchases,
   :purchase_items, :result_units, :shelves, :sales, :sale_items, :sie_exports, :sie_imports, :stock_values,
   :sie_transactions, :stock_value_items, :suppliers, :table_transactions, :tax_codes, :tax_returns,
   :tax_return_reports, :tax_tables, :tax_table_rows, :templates, :template_items, :transfers, :units,
   :vat_periods, :vat_reports, :vats, :verificates, :verificate_items, :wage_periods, :wage_reports, :wages,
   :warehouses].each do |model_sym|
    has_many model_sym
  end

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :organization_type, inclusion: { in: TYPES }

  before_validation :generate_slug

  def can_delete?
    false
  end

  def generate_slug
    self.slug = name.parameterize if name
  end
end
