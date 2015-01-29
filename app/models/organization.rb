class Organization < ActiveRecord::Base
  # t.string :slug, null: false, unique: true
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.string :vat_number
  # t.string :bankgiro
  # t.string :postgiro
  # t.string :plusgiro
  # t.string :swift
  # t.string :iban
  # t.timestamps

  attr_accessible :email, :name, :address, :zip, :vat_number, :bankgiro, :postgiro, :plusgiro, :city

  has_many :organization_roles
  has_many :users, through: :organization_roles

  [:accounting_classes, :accounting_groups, :accounting_periods, :accounting_plans, :accounts,
  :batches, :batch_transactions, :closing_balances, :comments, :contact_relations, 
  :contacts, :customers, :documents, :imports, :ink_codes, :inventories, :items, :ledgers, 
  :ledger_accounts, :ledger_transactions, :manuals, :materials, :opening_balances, 
  :opening_balance_items, :productions, :purchases, :purchase_items, :shelves, :sales, 
  :sale_items, :suppliers, :tax_codes, :templates, :template_items, :transfers, :units, 
  :vats, :verificates, :verificate_items, :warehouses].each do |model_sym|
    has_many model_sym
  end

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  def can_delete?
    false
  end

  def generate_slug
    self.slug = name.parameterize if name
  end
end
