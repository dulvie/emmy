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

  [:accounting_classes, :accounting_groups, :accounting_periods, :accounting_plans, :batches, :batch_transactions, :comments, :contact_relations, 
  :contacts, :customers, :documents, :imports, :ink_codes, :inventories, :items,  :manuals, :materials, :productions, :purchases, 
  :purchase_items, :shelves, :sales, :sale_items, :suppliers, :tax_codes, :transfers,
   :units, :vats, :warehouses].each do |model_sym|
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
