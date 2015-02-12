# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150206121447) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_classes", force: true do |t|
    t.string   "number"
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_groups", force: true do |t|
    t.string   "number"
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_periods", force: true do |t|
    t.string   "name"
    t.datetime "accounting_from"
    t.datetime "accounting_to"
    t.string   "vat_period_type"
    t.boolean  "active"
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_plans", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_name"
  end

  create_table "accounts", force: true do |t|
    t.integer  "number"
    t.string   "description"
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.integer  "accounting_class_id"
    t.integer  "accounting_group_id"
    t.integer  "tax_code_id"
    t.integer  "ink_code_id"
    t.integer  "ne_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_transactions", force: true do |t|
    t.integer  "organization_id"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "batch_id"
    t.integer  "warehouse_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batches", force: true do |t|
    t.integer  "item_id"
    t.integer  "organization_id"
    t.string   "name"
    t.text     "comment"
    t.integer  "in_price"
    t.integer  "distributor_price"
    t.integer  "retail_price"
    t.datetime "refined_at"
    t.datetime "expire_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "batches", ["name", "organization_id"], name: "index_batches_on_name_and_organization_id", unique: true, using: :btree

  create_table "closing_balance_items", force: true do |t|
    t.integer  "account_id"
    t.string   "description"
    t.decimal  "debit",                precision: 11, scale: 2
    t.decimal  "credit",               precision: 11, scale: 2
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "closing_balance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "closing_balances", force: true do |t|
    t.datetime "posting_date"
    t.string   "description"
    t.string   "state"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.integer  "organization_id"
    t.text     "body"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_relations", force: true do |t|
    t.integer  "organization_id"
    t.integer  "warehouse_id"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "email"
    t.string   "telephone"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.string   "country"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["email", "organization_id"], name: "index_contacts_on_email_and_organization_id", unique: true, using: :btree

  create_table "conversions", force: true do |t|
    t.integer  "old_number"
    t.integer  "new_number"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: true do |t|
    t.integer  "organization_id",    null: false
    t.string   "address"
    t.string   "city"
    t.string   "vat_number"
    t.string   "name",               null: false
    t.string   "zip"
    t.string   "country"
    t.string   "email"
    t.string   "telephone"
    t.boolean  "reseller"
    t.integer  "primary_contact_id"
    t.integer  "payment_term"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["name", "organization_id"], name: "index_customers_on_name_and_organization_id", unique: true, using: :btree

  create_table "documents", force: true do |t|
    t.integer  "organization_id"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.string   "name"
    t.integer  "birth_year"
    t.datetime "begin"
    t.datetime "ending"
    t.decimal  "salary",          precision: 6, scale: 0
    t.decimal  "tax",             precision: 6, scale: 0
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_bank_file_rows", force: true do |t|
    t.datetime "posting_date"
    t.decimal  "amount",              precision: 9,  scale: 2
    t.string   "bank_account"
    t.string   "name"
    t.string   "reference"
    t.decimal  "bank_balance",        precision: 11, scale: 2
    t.string   "note"
    t.boolean  "posted"
    t.integer  "organization_id"
    t.integer  "import_bank_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_bank_files", force: true do |t|
    t.datetime "import_date"
    t.datetime "from_date"
    t.datetime "to_date"
    t.string   "reference"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", force: true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "description"
    t.integer  "our_reference_id"
    t.integer  "to_warehouse_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.integer  "amount"
    t.integer  "cost_price"
    t.integer  "importing_id"
    t.integer  "shipping_id"
    t.integer  "customs_id"
    t.string   "state"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ink_codes", force: true do |t|
    t.string   "code"
    t.string   "text"
    t.string   "sum_method"
    t.string   "bas_accounts"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventories", force: true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "warehouse_id"
    t.datetime "inventory_date"
    t.string   "state"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_items", force: true do |t|
    t.integer  "organization_id"
    t.integer  "inventory_id"
    t.integer  "batch_id"
    t.integer  "shelf_quantity"
    t.integer  "actual_quantity"
    t.boolean  "reported"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.integer  "organization_id"
    t.integer  "unit_id"
    t.integer  "vat_id"
    t.string   "name"
    t.text     "comment"
    t.string   "item_type"
    t.string   "item_group"
    t.boolean  "stocked"
    t.integer  "in_price"
    t.integer  "distributor_price"
    t.integer  "retail_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledger_accounts", force: true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "ledger_id"
    t.integer  "account_id"
    t.decimal  "sum",                  precision: 11, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledger_transactions", force: true do |t|
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "ledger_id"
    t.integer  "account_id"
    t.datetime "posting_date"
    t.integer  "number"
    t.string   "text"
    t.decimal  "sum",                  precision: 11, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledgers", force: true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manuals", force: true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "materials", force: true do |t|
    t.integer  "organization_id"
    t.integer  "production_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.string   "state"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ne_codes", force: true do |t|
    t.string   "code"
    t.string   "text"
    t.string   "sum_method"
    t.string   "bas_accounts"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opening_balance_items", force: true do |t|
    t.integer  "account_id"
    t.string   "description"
    t.decimal  "debit",                precision: 11, scale: 2
    t.decimal  "credit",               precision: 11, scale: 2
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "opening_balance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opening_balances", force: true do |t|
    t.string   "description"
    t.string   "state"
    t.datetime "posting_date"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_roles", force: true do |t|
    t.string  "name",            null: false
    t.integer "user_id",         null: false
    t.integer "organization_id", null: false
  end

  add_index "organization_roles", ["name", "user_id", "organization_id"], name: "organization_roles_index", unique: true, using: :btree

  create_table "organizations", force: true do |t|
    t.string   "slug",       null: false
    t.string   "email"
    t.string   "name"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.string   "vat_number"
    t.string   "bankgiro"
    t.string   "postgiro"
    t.string   "plusgiro"
    t.string   "swift"
    t.string   "iban"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "productions", force: true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "description"
    t.integer  "our_reference_id"
    t.integer  "warehouse_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.integer  "cost_price"
    t.integer  "total_amount"
    t.string   "state"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_items", force: true do |t|
    t.integer  "organization_id"
    t.integer  "purchase_id"
    t.integer  "item_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.integer  "price"
    t.integer  "amount"
    t.integer  "vat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchases", force: true do |t|
    t.integer  "organization_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "user_id"
    t.integer  "supplier_id"
    t.string   "contact_email"
    t.string   "contact_name"
    t.string   "description"
    t.integer  "our_reference_id"
    t.integer  "to_warehouse_id"
    t.string   "state"
    t.string   "goods_state"
    t.string   "money_state"
    t.datetime "completed_at"
    t.datetime "ordered_at"
    t.datetime "received_at"
    t.datetime "paid_at"
    t.datetime "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "result_units", force: true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sale_items", force: true do |t|
    t.integer  "organization_id"
    t.integer  "sale_id"
    t.integer  "item_id"
    t.integer  "batch_id"
    t.string   "name"
    t.integer  "quantity"
    t.integer  "price"
    t.integer  "price_inc_vat"
    t.integer  "price_sum"
    t.integer  "vat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales", force: true do |t|
    t.integer  "user_id"
    t.integer  "customer_id"
    t.integer  "warehouse_id"
    t.integer  "organization_id"
    t.string   "contact_email"
    t.string   "contact_telephone"
    t.string   "contact_name"
    t.integer  "payment_term"
    t.string   "state"
    t.string   "goods_state"
    t.string   "money_state"
    t.datetime "approved_at"
    t.datetime "delivered_at"
    t.datetime "paid_at"
    t.datetime "sent_email_at"
    t.integer  "invoice_number"
    t.datetime "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "canceled_at"
  end

  create_table "shelves", force: true do |t|
    t.integer  "organization_id"
    t.integer  "quantity",        default: 0
    t.integer  "warehouse_id"
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suppliers", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.string   "country"
    t.string   "bg_number"
    t.string   "vat_number"
    t.integer  "primary_contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suppliers", ["name", "organization_id"], name: "index_suppliers_on_name_and_organization_id", unique: true, using: :btree

  create_table "tax_codes", force: true do |t|
    t.integer  "code"
    t.string   "text"
    t.string   "sum_method"
    t.string   "code_type"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_return_reports", force: true do |t|
    t.integer  "amount"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "tax_return_id"
    t.integer  "ink_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_returns", force: true do |t|
    t.string   "name"
    t.datetime "deadline"
    t.string   "state"
    t.datetime "calculated_at"
    t.datetime "reported_at"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "template_items", force: true do |t|
    t.integer  "account_id"
    t.string   "description"
    t.boolean  "enable_debit"
    t.boolean  "enable_credit"
    t.integer  "organization_id"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "templates", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "template_type"
  end

  create_table "transfers", force: true do |t|
    t.integer  "from_warehouse_id"
    t.integer  "to_warehouse_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "state"
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "weight"
    t.string   "package_dimensions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["name", "organization_id"], name: "index_units_on_name_and_organization_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.integer  "default_locale",          default: 0
    t.integer  "default_organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                   default: "", null: false
    t.string   "encrypted_password",      default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vat_periods", force: true do |t|
    t.string   "name"
    t.datetime "vat_from"
    t.datetime "vat_to"
    t.datetime "deadline"
    t.string   "state"
    t.datetime "calculated_at"
    t.datetime "reported_at"
    t.datetime "closed_at"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vat_reports", force: true do |t|
    t.integer  "amount"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "vat_period_id"
    t.integer  "tax_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vats", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "vat_percent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vats", ["name", "organization_id"], name: "index_vats_on_name_and_organization_id", unique: true, using: :btree

  create_table "verificate_items", force: true do |t|
    t.integer  "account_id"
    t.string   "description"
    t.decimal  "debit",                precision: 11, scale: 2
    t.decimal  "credit",               precision: 11, scale: 2
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "verificate_id"
    t.integer  "result_unit_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "verificates", force: true do |t|
    t.integer  "number"
    t.string   "state"
    t.datetime "posting_date"
    t.string   "description"
    t.string   "reference"
    t.string   "note"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.string   "parent_extend"
  end

  create_table "wage_periods", force: true do |t|
    t.string   "name"
    t.datetime "wage_from"
    t.datetime "wage_to"
    t.datetime "payment_date"
    t.datetime "deadline"
    t.string   "state"
    t.datetime "wage_calculated_at"
    t.datetime "wage_reported_at"
    t.datetime "wage_closed_at"
    t.datetime "tax_calculated_at"
    t.datetime "tax_reported_at"
    t.datetime "tax_closed_at"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wage_reports", force: true do |t|
    t.integer  "amount"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "wage_period_id"
    t.integer  "tax_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wages", force: true do |t|
    t.datetime "wage_from"
    t.datetime "wage_to"
    t.datetime "payment_date"
    t.decimal  "salary",               precision: 9, scale: 2
    t.decimal  "addition",             precision: 9, scale: 2
    t.decimal  "discount",             precision: 9, scale: 2
    t.decimal  "tax",                  precision: 9, scale: 2
    t.decimal  "payroll_tax",          precision: 9, scale: 2
    t.decimal  "amount",               precision: 9, scale: 2
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "wage_period_id"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "warehouses", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.integer  "primary_contact_id"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "warehouses", ["name", "organization_id"], name: "index_warehouses_on_name_and_organization_id", unique: true, using: :btree

end
