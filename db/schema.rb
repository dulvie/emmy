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

ActiveRecord::Schema.define(version: 20160627152321) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_classes", force: :cascade do |t|
    t.string   "number",             limit: 255
    t.string   "name",               limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_groups", force: :cascade do |t|
    t.string   "number",             limit: 255
    t.string   "name",               limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_periods", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.datetime "accounting_from"
    t.datetime "accounting_to"
    t.string   "vat_period_type",    limit: 255
    t.boolean  "active"
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounting_plans", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "description",     limit: 255
    t.string   "file_name",       limit: 255
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer  "number"
    t.string   "description",         limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.integer  "accounting_class_id"
    t.integer  "accounting_group_id"
    t.integer  "tax_code_id"
    t.integer  "ink_code_id"
    t.integer  "ne_code_id"
    t.integer  "default_code_id"
    t.boolean  "active",                          default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_file_transactions", force: :cascade do |t|
    t.string   "parent_type",     limit: 255
    t.integer  "parent_id"
    t.string   "directory",       limit: 255
    t.string   "file_name",       limit: 255
    t.string   "execute",         limit: 255
    t.boolean  "complete"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_transactions", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "parent_type",     limit: 255
    t.integer  "parent_id"
    t.integer  "batch_id"
    t.integer  "warehouse_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batches", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "organization_id"
    t.string   "name",              limit: 255
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

  create_table "closing_balance_items", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "description",          limit: 255
    t.decimal  "debit",                            precision: 11, scale: 2
    t.decimal  "credit",                           precision: 11, scale: 2
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "closing_balance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "closing_balances", force: :cascade do |t|
    t.datetime "posting_date"
    t.string   "description",          limit: 255
    t.string   "state",                limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "organization_id"
    t.text     "body"
    t.string   "parent_type",     limit: 255
    t.integer  "parent_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_relations", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "warehouse_id"
    t.string   "parent_type",     limit: 255
    t.integer  "parent_id"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "telephone",       limit: 255
    t.string   "address",         limit: 255
    t.string   "zip",             limit: 255
    t.string   "city",            limit: 255
    t.string   "country",         limit: 255
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["email", "organization_id"], name: "index_contacts_on_email_and_organization_id", unique: true, using: :btree

  create_table "conversions", force: :cascade do |t|
    t.integer  "old_number"
    t.integer  "new_number"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: :cascade do |t|
    t.integer  "organization_id",                null: false
    t.string   "address",            limit: 255
    t.string   "city",               limit: 255
    t.string   "vat_number",         limit: 255
    t.string   "name",               limit: 255, null: false
    t.string   "zip",                limit: 255
    t.string   "country",            limit: 255
    t.string   "email",              limit: 255
    t.string   "telephone",          limit: 255
    t.boolean  "reseller"
    t.integer  "primary_contact_id"
    t.integer  "payment_term"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["name", "organization_id"], name: "index_customers_on_name_and_organization_id", unique: true, using: :btree

  create_table "default_code_headers", force: :cascade do |t|
    t.string   "name"
    t.string   "file_name"
    t.string   "run_type"
    t.integer  "accounting_plan_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  create_table "default_codes", force: :cascade do |t|
    t.integer  "code"
    t.string   "text",            limit: 255
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "parent_type",         limit: 255
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "name",                limit: 255
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "birth_year"
    t.datetime "begin"
    t.datetime "ending"
    t.decimal  "salary",                       precision: 6
    t.decimal  "tax",                          precision: 6
    t.integer  "tax_table_id"
    t.string   "tax_table_column", limit: 255
    t.string   "clearingnumber",   limit: 255
    t.string   "bank_account",     limit: 255
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "personal",         limit: 255
  end

  create_table "export_bank_file_rows", force: :cascade do |t|
    t.datetime "posting_date"
    t.decimal  "amount",                          precision: 9, scale: 2
    t.string   "bankgiro",            limit: 255
    t.string   "plusgiro",            limit: 255
    t.string   "clearingnumber",      limit: 255
    t.string   "bank_account",        limit: 255
    t.string   "ocr",                 limit: 255
    t.string   "name",                limit: 255
    t.string   "reference",           limit: 255
    t.datetime "bank_date"
    t.string   "currency_paid",       limit: 255
    t.string   "currency_debit",      limit: 255
    t.integer  "organization_id"
    t.integer  "export_bank_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "export_bank_files", force: :cascade do |t|
    t.datetime "export_date"
    t.datetime "from_date"
    t.datetime "to_date"
    t.string   "reference",             limit: 255
    t.string   "organization_number",   limit: 255
    t.string   "pay_account",           limit: 255
    t.string   "iban",                  limit: 255
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                 limit: 255
    t.string   "download_file_name",    limit: 255
    t.string   "download_content_type", limit: 255
    t.integer  "download_file_size"
    t.datetime "download_updated_at"
  end

  create_table "import_bank_file_rows", force: :cascade do |t|
    t.datetime "posting_date"
    t.decimal  "amount",                          precision: 9,  scale: 2
    t.string   "bank_account",        limit: 255
    t.string   "name",                limit: 255
    t.string   "reference",           limit: 255
    t.decimal  "bank_balance",                    precision: 11, scale: 2
    t.string   "note",                limit: 255
    t.boolean  "posted"
    t.integer  "organization_id"
    t.integer  "import_bank_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_bank_files", force: :cascade do |t|
    t.datetime "import_date"
    t.datetime "from_date"
    t.datetime "to_date"
    t.string   "reference",           limit: 255
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",               limit: 255
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  create_table "imports", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "description",      limit: 255
    t.integer  "our_reference_id"
    t.integer  "to_warehouse_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.integer  "amount"
    t.integer  "cost_price"
    t.integer  "importing_id"
    t.integer  "shipping_id"
    t.integer  "customs_id"
    t.string   "state",            limit: 255
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ink_code_headers", force: :cascade do |t|
    t.string   "name"
    t.string   "file_name"
    t.string   "run_type"
    t.string   "state"
    t.integer  "accounting_plan_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ink_codes", force: :cascade do |t|
    t.string   "code",            limit: 255
    t.string   "text",            limit: 255
    t.string   "sum_method",      limit: 255
    t.string   "bas_accounts",    limit: 255
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventories", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "warehouse_id"
    t.datetime "inventory_date"
    t.string   "state",           limit: 255
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "inventory_id"
    t.integer  "batch_id"
    t.integer  "shelf_quantity"
    t.integer  "actual_quantity"
    t.boolean  "reported"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "unit_id"
    t.integer  "vat_id"
    t.string   "name",              limit: 255
    t.text     "comment"
    t.string   "item_type",         limit: 255
    t.string   "item_group",        limit: 255
    t.boolean  "stocked"
    t.integer  "in_price"
    t.integer  "distributor_price"
    t.integer  "retail_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledger_accounts", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "ledger_id"
    t.integer  "account_id"
    t.decimal  "sum",                              precision: 11, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledger_transactions", force: :cascade do |t|
    t.string   "parent_type",          limit: 255
    t.integer  "parent_id"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "ledger_id"
    t.integer  "account_id"
    t.datetime "posting_date"
    t.integer  "number"
    t.string   "text",                 limit: 255
    t.decimal  "sum",                              precision: 11, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledgers", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manuals", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "materials", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "production_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.string   "state",           limit: 255
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ne_code_headers", force: :cascade do |t|
    t.string   "name"
    t.string   "file_name"
    t.string   "run_type"
    t.string   "state"
    t.integer  "accounting_plan_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ne_codes", force: :cascade do |t|
    t.string   "code",            limit: 255
    t.string   "text",            limit: 255
    t.string   "sum_method",      limit: 255
    t.string   "bas_accounts",    limit: 255
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opening_balance_items", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "description",          limit: 255
    t.decimal  "debit",                            precision: 11, scale: 2
    t.decimal  "credit",                           precision: 11, scale: 2
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "opening_balance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opening_balances", force: :cascade do |t|
    t.string   "description",          limit: 255
    t.string   "state",                limit: 255
    t.datetime "posting_date"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_roles", force: :cascade do |t|
    t.string  "name",            limit: 255, null: false
    t.integer "user_id",                     null: false
    t.integer "organization_id",             null: false
  end

  add_index "organization_roles", ["name", "user_id", "organization_id"], name: "organization_roles_index", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "slug",                limit: 255, null: false
    t.string   "email",               limit: 255
    t.string   "name",                limit: 255
    t.string   "address",             limit: 255
    t.string   "zip",                 limit: 255
    t.string   "city",                limit: 255
    t.string   "vat_number",          limit: 255
    t.string   "bankgiro",            limit: 255
    t.string   "postgiro",            limit: 255
    t.string   "plusgiro",            limit: 255
    t.string   "swift",               limit: 255
    t.string   "iban",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "organization_number", limit: 255
    t.string   "organization_type",   limit: 255
  end

  create_table "productions", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "description",      limit: 255
    t.integer  "our_reference_id"
    t.integer  "warehouse_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.integer  "cost_price"
    t.integer  "total_amount"
    t.string   "state",            limit: 255
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_items", force: :cascade do |t|
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

  create_table "purchases", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "parent_id"
    t.string   "parent_type",        limit: 255
    t.integer  "user_id"
    t.integer  "supplier_id"
    t.string   "contact_email",      limit: 255
    t.string   "contact_name",       limit: 255
    t.string   "description",        limit: 255
    t.integer  "our_reference_id"
    t.integer  "to_warehouse_id"
    t.string   "state",              limit: 255
    t.string   "goods_state",        limit: 255
    t.string   "money_state",        limit: 255
    t.datetime "completed_at"
    t.datetime "ordered_at"
    t.datetime "received_at"
    t.datetime "paid_at"
    t.datetime "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "supplier_reference", limit: 255
  end

  create_table "result_units", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sale_items", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "sale_id"
    t.integer  "item_id"
    t.integer  "batch_id"
    t.string   "name",            limit: 255
    t.integer  "quantity"
    t.integer  "price"
    t.integer  "price_inc_vat"
    t.integer  "price_sum"
    t.integer  "vat"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "customer_id"
    t.integer  "warehouse_id"
    t.integer  "organization_id"
    t.string   "contact_email",     limit: 255
    t.string   "contact_telephone", limit: 255
    t.string   "contact_name",      limit: 255
    t.integer  "payment_term"
    t.string   "state",             limit: 255
    t.string   "goods_state",       limit: 255
    t.string   "money_state",       limit: 255
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

  create_table "shelves", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "quantity",        default: 0
    t.integer  "warehouse_id"
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sie_exports", force: :cascade do |t|
    t.datetime "export_date"
    t.string   "sie_type"
    t.string   "state"
    t.string   "download_file_name"
    t.string   "download_content_type"
    t.integer  "download_file_size"
    t.datetime "download_updated_at"
    t.integer  "accounting_period_id"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sie_imports", force: :cascade do |t|
    t.datetime "import_date"
    t.string   "sie_type",             limit: 255
    t.string   "upload_file_name",     limit: 255
    t.string   "upload_content_type",  limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.string   "state",                limit: 255
    t.integer  "accounting_period_id"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sie_transactions", force: :cascade do |t|
    t.string   "directory",            limit: 255
    t.string   "file_name",            limit: 255
    t.string   "execute",              limit: 255
    t.string   "sie_type",             limit: 255
    t.boolean  "complete"
    t.integer  "accounting_period_id"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_value_items", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.decimal  "price",                       precision: 11, scale: 2, default: 0.0
    t.integer  "quantity"
    t.integer  "value"
    t.integer  "organization_id"
    t.integer  "stock_value_id"
    t.integer  "warehouse_id"
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_values", force: :cascade do |t|
    t.datetime "value_date"
    t.string   "name",            limit: 255
    t.text     "comment"
    t.integer  "value"
    t.string   "state",           limit: 255
    t.datetime "reported_at"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suppliers", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "name",               limit: 255
    t.string   "address",            limit: 255
    t.string   "zip",                limit: 255
    t.string   "city",               limit: 255
    t.string   "country",            limit: 255
    t.string   "vat_number",         limit: 255
    t.integer  "primary_contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reference",          limit: 255
    t.string   "bankgiro",           limit: 255
    t.string   "postgiro",           limit: 255
    t.string   "plusgiro",           limit: 255
    t.string   "supplier_type",      limit: 255
  end

  add_index "suppliers", ["name", "organization_id"], name: "index_suppliers_on_name_and_organization_id", unique: true, using: :btree

  create_table "table_transactions", force: :cascade do |t|
    t.string   "directory",       limit: 255
    t.string   "file_name",       limit: 255
    t.string   "execute",         limit: 255
    t.integer  "year"
    t.string   "table",           limit: 255
    t.boolean  "complete"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_agency_transactions", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "parent_type",     limit: 255
    t.integer  "parent_id"
    t.datetime "posting_date"
    t.string   "report_type",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_code_headers", force: :cascade do |t|
    t.string   "name"
    t.string   "file_name"
    t.string   "run_type"
    t.string   "state"
    t.integer  "accounting_plan_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_codes", force: :cascade do |t|
    t.integer  "code"
    t.string   "text",            limit: 255
    t.string   "sum_method",      limit: 255
    t.string   "code_type",       limit: 255
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_return_reports", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "tax_return_id"
    t.integer  "ink_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_returns", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "tax_form",             limit: 255
    t.datetime "deadline"
    t.string   "state",                limit: 255
    t.datetime "calculated_at"
    t.datetime "reported_at"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_table_rows", force: :cascade do |t|
    t.string   "calculation",     limit: 255
    t.integer  "from_wage"
    t.integer  "to_wage"
    t.integer  "column_1"
    t.integer  "column_2"
    t.integer  "column_3"
    t.integer  "column_4"
    t.integer  "column_5"
    t.integer  "column_6"
    t.integer  "organization_id"
    t.integer  "tax_table_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_tables", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "year"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_name"
    t.string   "table_name"
    t.string   "state"
  end

  create_table "template_items", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "description",     limit: 255
    t.boolean  "enable_debit"
    t.boolean  "enable_credit"
    t.integer  "organization_id"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "templates", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "description",        limit: 255
    t.string   "template_type",      limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transfers", force: :cascade do |t|
    t.integer  "from_warehouse_id"
    t.integer  "to_warehouse_id"
    t.integer  "batch_id"
    t.integer  "quantity"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "state",             limit: 255
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "name",               limit: 255
    t.string   "weight",             limit: 255
    t.string   "package_dimensions", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["name", "organization_id"], name: "index_units_on_name_and_organization_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.integer  "default_locale",                      default: 0
    t.integer  "default_organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                   limit: 255, default: "", null: false
    t.string   "encrypted_password",      limit: 255, default: "", null: false
    t.string   "reset_password_token",    limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",      limit: 255
    t.string   "last_sign_in_ip",         limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vat_periods", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.datetime "vat_from"
    t.datetime "vat_to"
    t.datetime "deadline"
    t.string   "state",                limit: 255
    t.datetime "calculated_at"
    t.datetime "reported_at"
    t.datetime "closed_at"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vat_reports", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "code"
    t.string   "text",                 limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "vat_period_id"
    t.integer  "tax_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vats", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "name",            limit: 255
    t.integer  "vat_percent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vats", ["name", "organization_id"], name: "index_vats_on_name_and_organization_id", unique: true, using: :btree

  create_table "verificate_items", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "description",          limit: 255
    t.decimal  "debit",                            precision: 11, scale: 2, default: 0.0
    t.decimal  "credit",                           precision: 11, scale: 2, default: 0.0
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "verificate_id"
    t.integer  "result_unit_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "verificate_transactions", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "parent_type",     limit: 255
    t.integer  "parent_id"
    t.datetime "posting_date"
    t.string   "verificate_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "verificates", force: :cascade do |t|
    t.integer  "number"
    t.string   "state",                   limit: 255
    t.datetime "posting_date"
    t.string   "description",             limit: 255
    t.string   "reference",               limit: 255
    t.string   "note",                    limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "template_id"
    t.string   "parent_type",             limit: 255
    t.integer  "parent_id"
    t.string   "parent_extend",           limit: 255
    t.integer  "import_bank_file_row_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wage_periods", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.datetime "wage_from"
    t.datetime "wage_to"
    t.datetime "payment_date"
    t.datetime "deadline"
    t.string   "state",                limit: 255
    t.datetime "wage_calculated_at"
    t.datetime "wage_reported_at"
    t.datetime "wage_closed_at"
    t.datetime "tax_calculated_at"
    t.datetime "tax_reported_at"
    t.datetime "tax_closed_at"
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wage_reports", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "code"
    t.string   "text",                 limit: 255
    t.integer  "organization_id"
    t.integer  "accounting_period_id"
    t.integer  "wage_period_id"
    t.integer  "tax_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wages", force: :cascade do |t|
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

  create_table "warehouses", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "name",               limit: 255
    t.integer  "primary_contact_id"
    t.string   "address",            limit: 255
    t.string   "zip",                limit: 255
    t.string   "city",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "warehouses", ["name", "organization_id"], name: "index_warehouses_on_name_and_organization_id", unique: true, using: :btree

end
