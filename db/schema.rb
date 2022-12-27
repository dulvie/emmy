# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2018_05_03_125846) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_classes", id: :serial, force: :cascade do |t|
    t.string "number", limit: 255
    t.string "name", limit: 255
    t.integer "organization_id"
    t.integer "accounting_plan_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "accounting_groups", id: :serial, force: :cascade do |t|
    t.string "number", limit: 255
    t.string "name", limit: 255
    t.integer "organization_id"
    t.integer "accounting_plan_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "accounting_periods", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "accounting_from", precision: nil
    t.datetime "accounting_to", precision: nil
    t.string "vat_period_type", limit: 255
    t.boolean "active"
    t.integer "organization_id"
    t.integer "accounting_plan_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "accounting_plans", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.string "file_name", limit: 255
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "state"
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.string "description", limit: 255
    t.integer "organization_id"
    t.integer "accounting_plan_id"
    t.integer "accounting_class_id"
    t.integer "accounting_group_id"
    t.integer "tax_code_id"
    t.integer "ink_code_id"
    t.integer "ne_code_id"
    t.integer "default_code_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "bank_file_transactions", id: :serial, force: :cascade do |t|
    t.string "parent_type", limit: 255
    t.integer "parent_id"
    t.string "directory", limit: 255
    t.string "file_name", limit: 255
    t.string "execute", limit: 255
    t.boolean "complete"
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "batch_transactions", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "parent_type", limit: 255
    t.integer "parent_id"
    t.integer "batch_id"
    t.integer "warehouse_id"
    t.integer "quantity"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "batches", id: :serial, force: :cascade do |t|
    t.integer "item_id"
    t.integer "organization_id"
    t.string "name", limit: 255
    t.text "comment"
    t.integer "in_price"
    t.integer "distributor_price"
    t.integer "retail_price"
    t.datetime "refined_at", precision: nil
    t.datetime "expire_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name", "organization_id"], name: "index_batches_on_name_and_organization_id", unique: true
  end

  create_table "closing_balance_items", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "description", limit: 255
    t.decimal "debit", precision: 11, scale: 2
    t.decimal "credit", precision: 11, scale: 2
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "closing_balance_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "closing_balances", id: :serial, force: :cascade do |t|
    t.datetime "posting_date", precision: nil
    t.string "description", limit: 255
    t.string "state", limit: 255
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.text "body"
    t.string "parent_type", limit: 255
    t.integer "parent_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "contact_relations", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "warehouse_id"
    t.string "parent_type", limit: 255
    t.integer "parent_id"
    t.integer "contact_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.string "telephone", limit: 255
    t.string "address", limit: 255
    t.string "zip", limit: 255
    t.string "city", limit: 255
    t.string "country", limit: 255
    t.text "comment"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email", "organization_id"], name: "index_contacts_on_email_and_organization_id", unique: true
  end

  create_table "conversions", id: :serial, force: :cascade do |t|
    t.integer "old_number"
    t.integer "new_number"
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "customers", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "address", limit: 255
    t.string "city", limit: 255
    t.string "vat_number", limit: 255
    t.string "name", limit: 255, null: false
    t.string "zip", limit: 255
    t.string "country", limit: 255
    t.string "email", limit: 255
    t.string "telephone", limit: 255
    t.boolean "reseller"
    t.integer "primary_contact_id"
    t.integer "payment_term"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name", "organization_id"], name: "index_customers_on_name_and_organization_id", unique: true
  end

  create_table "default_code_headers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "file_name"
    t.string "run_type"
    t.string "state"
    t.integer "accounting_plan_id"
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "default_codes", id: :serial, force: :cascade do |t|
    t.integer "code"
    t.string "text", limit: 255
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "parent_type", limit: 255
    t.integer "parent_id"
    t.integer "user_id"
    t.string "name", limit: 255
    t.string "upload_file_name", limit: 255
    t.string "upload_content_type", limit: 255
    t.integer "upload_file_size"
    t.datetime "upload_updated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "employees", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "birth_year"
    t.datetime "begin", precision: nil
    t.datetime "ending", precision: nil
    t.decimal "salary", precision: 6
    t.decimal "tax", precision: 6
    t.integer "tax_table_id"
    t.string "tax_table_column", limit: 255
    t.string "clearingnumber", limit: 255
    t.string "bank_account", limit: 255
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "personal", limit: 255
    t.string "wage_type"
  end

  create_table "export_bank_file_rows", id: :serial, force: :cascade do |t|
    t.datetime "posting_date", precision: nil
    t.decimal "amount", precision: 9, scale: 2
    t.string "bankgiro", limit: 255
    t.string "plusgiro", limit: 255
    t.string "clearingnumber", limit: 255
    t.string "bank_account", limit: 255
    t.string "ocr", limit: 255
    t.string "name", limit: 255
    t.string "reference", limit: 255
    t.datetime "bank_date", precision: nil
    t.string "currency_paid", limit: 255
    t.string "currency_debit", limit: 255
    t.integer "organization_id"
    t.integer "export_bank_file_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "export_bank_files", id: :serial, force: :cascade do |t|
    t.datetime "export_date", precision: nil
    t.datetime "from_date", precision: nil
    t.datetime "to_date", precision: nil
    t.string "reference", limit: 255
    t.string "organization_number", limit: 255
    t.string "pay_account", limit: 255
    t.string "iban", limit: 255
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "state"
    t.string "download_file_name"
    t.string "download_content_type"
    t.integer "download_file_size"
    t.datetime "download_updated_at", precision: nil
  end

  create_table "import_bank_file_rows", id: :serial, force: :cascade do |t|
    t.datetime "posting_date", precision: nil
    t.decimal "amount", precision: 9, scale: 2
    t.string "bank_account", limit: 255
    t.string "name", limit: 255
    t.string "reference", limit: 255
    t.decimal "bank_balance", precision: 11, scale: 2
    t.string "note", limit: 255
    t.boolean "posted"
    t.integer "organization_id"
    t.integer "import_bank_file_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "import_bank_files", id: :serial, force: :cascade do |t|
    t.datetime "import_date", precision: nil
    t.datetime "from_date", precision: nil
    t.datetime "to_date", precision: nil
    t.string "reference", limit: 255
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "state", limit: 255
    t.string "upload_file_name", limit: 255
    t.string "upload_content_type", limit: 255
    t.integer "upload_file_size"
    t.datetime "upload_updated_at", precision: nil
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "user_id"
    t.string "description", limit: 255
    t.integer "our_reference_id"
    t.integer "to_warehouse_id"
    t.integer "batch_id"
    t.integer "quantity"
    t.integer "amount"
    t.integer "cost_price"
    t.integer "importing_id"
    t.integer "shipping_id"
    t.integer "customs_id"
    t.string "state", limit: 255
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ink_code_headers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "file_name"
    t.string "run_type"
    t.string "state"
    t.integer "accounting_plan_id"
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ink_codes", id: :serial, force: :cascade do |t|
    t.string "code", limit: 255
    t.string "text", limit: 255
    t.string "sum_method", limit: 255
    t.string "bas_accounts", limit: 255
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "inventories", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "user_id"
    t.integer "warehouse_id"
    t.datetime "inventory_date", precision: nil
    t.string "state", limit: 255
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "inventory_items", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "inventory_id"
    t.integer "batch_id"
    t.integer "shelf_quantity"
    t.integer "actual_quantity"
    t.boolean "reported"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "unit_id"
    t.integer "vat_id"
    t.string "name", limit: 255
    t.text "comment"
    t.string "item_type", limit: 255
    t.string "item_group", limit: 255
    t.boolean "stocked"
    t.integer "in_price"
    t.integer "distributor_price"
    t.integer "retail_price"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ledger_accounts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "ledger_id"
    t.integer "account_id"
    t.decimal "sum", precision: 11, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ledger_transactions", id: :serial, force: :cascade do |t|
    t.string "parent_type", limit: 255
    t.integer "parent_id"
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "ledger_id"
    t.integer "account_id"
    t.datetime "posting_date", precision: nil
    t.integer "number"
    t.string "text", limit: 255
    t.decimal "sum", precision: 11, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ledgers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "mail_templates", force: :cascade do |t|
    t.string "name"
    t.string "template_type"
    t.string "subject"
    t.string "attachment"
    t.text "text"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "manuals", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "materials", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "production_id"
    t.integer "batch_id"
    t.integer "quantity"
    t.string "state", limit: 255
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ne_code_headers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "file_name"
    t.string "run_type"
    t.string "state"
    t.integer "accounting_plan_id"
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ne_codes", id: :serial, force: :cascade do |t|
    t.string "code", limit: 255
    t.string "text", limit: 255
    t.string "sum_method", limit: 255
    t.string "bas_accounts", limit: 255
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "opening_balance_items", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "description", limit: 255
    t.decimal "debit", precision: 11, scale: 2
    t.decimal "credit", precision: 11, scale: 2
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "opening_balance_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "opening_balances", id: :serial, force: :cascade do |t|
    t.string "description", limit: 255
    t.string "state", limit: 255
    t.datetime "posting_date", precision: nil
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "organization_roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "user_id", null: false
    t.integer "organization_id", null: false
    t.index ["name", "user_id", "organization_id"], name: "organization_roles_index", unique: true
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 255, null: false
    t.string "email", limit: 255
    t.string "name", limit: 255
    t.string "address", limit: 255
    t.string "zip", limit: 255
    t.string "city", limit: 255
    t.string "vat_number", limit: 255
    t.string "bankgiro", limit: 255
    t.string "postgiro", limit: 255
    t.string "plusgiro", limit: 255
    t.string "swift", limit: 255
    t.string "iban", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "organization_number", limit: 255
    t.string "organization_type", limit: 255
    t.string "invoice_text"
  end

  create_table "productions", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "user_id"
    t.string "description", limit: 255
    t.integer "our_reference_id"
    t.integer "warehouse_id"
    t.integer "batch_id"
    t.integer "quantity"
    t.integer "cost_price"
    t.integer "total_amount"
    t.string "state", limit: 255
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "purchase_items", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "purchase_id"
    t.integer "item_id"
    t.integer "batch_id"
    t.integer "quantity"
    t.integer "price"
    t.integer "amount"
    t.integer "vat"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "purchases", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "parent_id"
    t.string "parent_type", limit: 255
    t.integer "user_id"
    t.integer "supplier_id"
    t.string "contact_email", limit: 255
    t.string "contact_name", limit: 255
    t.string "description", limit: 255
    t.integer "our_reference_id"
    t.integer "to_warehouse_id"
    t.string "state", limit: 255
    t.string "goods_state", limit: 255
    t.string "money_state", limit: 255
    t.datetime "completed_at", precision: nil
    t.datetime "ordered_at", precision: nil
    t.datetime "received_at", precision: nil
    t.datetime "paid_at", precision: nil
    t.datetime "due_date", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "supplier_reference", limit: 255
  end

  create_table "result_units", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "employee_id"
  end

  create_table "reversed_vat_reports", force: :cascade do |t|
    t.string "vat_number"
    t.integer "goods"
    t.integer "services"
    t.integer "third_part"
    t.string "note"
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "reversed_vat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reversed_vats", force: :cascade do |t|
    t.string "name"
    t.datetime "vat_from"
    t.datetime "vat_to"
    t.string "state"
    t.datetime "calculated_at"
    t.datetime "reported_at"
    t.datetime "deadline"
    t.integer "accounting_period_id"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sale_items", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "sale_id"
    t.integer "item_id"
    t.integer "batch_id"
    t.string "name", limit: 255
    t.integer "quantity"
    t.integer "price"
    t.integer "price_inc_vat"
    t.integer "price_sum"
    t.integer "vat"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "sales", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "customer_id"
    t.integer "warehouse_id"
    t.integer "organization_id"
    t.string "contact_email", limit: 255
    t.string "contact_telephone", limit: 255
    t.string "contact_name", limit: 255
    t.integer "payment_term"
    t.string "state", limit: 255
    t.string "goods_state", limit: 255
    t.string "money_state", limit: 255
    t.datetime "approved_at", precision: nil
    t.datetime "delivered_at", precision: nil
    t.datetime "paid_at", precision: nil
    t.datetime "sent_email_at", precision: nil
    t.integer "invoice_number"
    t.datetime "due_date", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "canceled_at", precision: nil
    t.text "invoice_text"
  end

  create_table "shelves", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.integer "quantity", default: 0
    t.integer "warehouse_id"
    t.integer "batch_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "sie_exports", id: :serial, force: :cascade do |t|
    t.datetime "export_date", precision: nil
    t.string "sie_type"
    t.string "state"
    t.string "download_file_name"
    t.string "download_content_type"
    t.integer "download_file_size"
    t.datetime "download_updated_at", precision: nil
    t.integer "accounting_period_id"
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "sie_imports", id: :serial, force: :cascade do |t|
    t.datetime "import_date", precision: nil
    t.string "sie_type", limit: 255
    t.string "upload_file_name", limit: 255
    t.string "upload_content_type", limit: 255
    t.integer "upload_file_size"
    t.datetime "upload_updated_at", precision: nil
    t.string "state", limit: 255
    t.integer "accounting_period_id"
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "sie_transactions", id: :serial, force: :cascade do |t|
    t.string "directory", limit: 255
    t.string "file_name", limit: 255
    t.string "execute", limit: 255
    t.string "sie_type", limit: 255
    t.boolean "complete"
    t.integer "accounting_period_id"
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "stock_value_items", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.decimal "price", precision: 11, scale: 2, default: "0.0"
    t.integer "quantity"
    t.integer "value"
    t.integer "organization_id"
    t.integer "stock_value_id"
    t.integer "warehouse_id"
    t.integer "batch_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "stock_values", id: :serial, force: :cascade do |t|
    t.datetime "value_date", precision: nil
    t.string "name", limit: 255
    t.text "comment"
    t.integer "value"
    t.string "state", limit: 255
    t.datetime "reported_at", precision: nil
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "suppliers", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.string "address", limit: 255
    t.string "zip", limit: 255
    t.string "city", limit: 255
    t.string "country", limit: 255
    t.string "vat_number", limit: 255
    t.integer "primary_contact_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "reference", limit: 255
    t.string "bankgiro", limit: 255
    t.string "postgiro", limit: 255
    t.string "plusgiro", limit: 255
    t.string "supplier_type", limit: 255
    t.index ["name", "organization_id"], name: "index_suppliers_on_name_and_organization_id", unique: true
  end

  create_table "table_transactions", id: :serial, force: :cascade do |t|
    t.string "directory", limit: 255
    t.string "file_name", limit: 255
    t.string "execute", limit: 255
    t.integer "year"
    t.string "table", limit: 255
    t.boolean "complete"
    t.integer "organization_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tax_code_headers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "file_name"
    t.string "run_type"
    t.string "state"
    t.integer "accounting_plan_id"
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tax_codes", id: :serial, force: :cascade do |t|
    t.integer "code"
    t.string "text", limit: 255
    t.string "sum_method", limit: 255
    t.string "code_type", limit: 255
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tax_return_reports", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "tax_return_id"
    t.integer "ink_code_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tax_returns", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "tax_form", limit: 255
    t.datetime "deadline", precision: nil
    t.string "state", limit: 255
    t.datetime "calculated_at", precision: nil
    t.datetime "reported_at", precision: nil
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tax_table_rows", id: :serial, force: :cascade do |t|
    t.string "calculation", limit: 255
    t.integer "from_wage"
    t.integer "to_wage"
    t.integer "column_1"
    t.integer "column_2"
    t.integer "column_3"
    t.integer "column_4"
    t.integer "column_5"
    t.integer "column_6"
    t.integer "organization_id"
    t.integer "tax_table_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tax_tables", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "year"
    t.integer "organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "file_name"
    t.string "table_name"
    t.string "state"
  end

  create_table "template_items", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "description", limit: 255
    t.boolean "enable_debit"
    t.boolean "enable_credit"
    t.integer "organization_id"
    t.integer "template_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "enable_result_unit"
  end

  create_table "templates", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.string "template_type", limit: 255
    t.integer "organization_id"
    t.integer "accounting_plan_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "transfers", id: :serial, force: :cascade do |t|
    t.integer "from_warehouse_id"
    t.integer "to_warehouse_id"
    t.integer "batch_id"
    t.integer "quantity"
    t.integer "user_id"
    t.integer "organization_id"
    t.string "state", limit: 255
    t.datetime "sent_at", precision: nil
    t.datetime "received_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.string "weight", limit: 255
    t.string "package_dimensions", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name", "organization_id"], name: "index_units_on_name_and_organization_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "default_locale", default: 0
    t.integer "default_organization_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vat_periods", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "vat_from", precision: nil
    t.datetime "vat_to", precision: nil
    t.datetime "deadline", precision: nil
    t.string "state", limit: 255
    t.datetime "calculated_at", precision: nil
    t.datetime "reported_at", precision: nil
    t.datetime "closed_at", precision: nil
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "supplier_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "vat_reports", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.integer "code"
    t.string "text", limit: 255
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "vat_period_id"
    t.integer "tax_code_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "vats", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.integer "vat_percent"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name", "organization_id"], name: "index_vats_on_name_and_organization_id", unique: true
  end

  create_table "verificate_items", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "description", limit: 255
    t.decimal "debit", precision: 11, scale: 2, default: "0.0"
    t.decimal "credit", precision: 11, scale: 2, default: "0.0"
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "verificate_id"
    t.integer "result_unit_id"
    t.integer "project_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "tax_code_id"
  end

  create_table "verificates", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.string "state", limit: 255
    t.datetime "posting_date", precision: nil
    t.string "description", limit: 255
    t.string "reference", limit: 255
    t.string "note", limit: 255
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "template_id"
    t.string "parent_type", limit: 255
    t.integer "parent_id"
    t.string "parent_extend", limit: 255
    t.integer "import_bank_file_row_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wage_periods", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "wage_from", precision: nil
    t.datetime "wage_to", precision: nil
    t.datetime "payment_date", precision: nil
    t.datetime "deadline", precision: nil
    t.string "state", limit: 255
    t.datetime "wage_calculated_at", precision: nil
    t.datetime "wage_reported_at", precision: nil
    t.datetime "wage_closed_at", precision: nil
    t.datetime "tax_calculated_at", precision: nil
    t.datetime "tax_reported_at", precision: nil
    t.datetime "tax_closed_at", precision: nil
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "supplier_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wage_reports", id: :serial, force: :cascade do |t|
    t.integer "amount"
    t.integer "code"
    t.string "text", limit: 255
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "wage_period_id"
    t.integer "tax_code_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "wages", id: :serial, force: :cascade do |t|
    t.datetime "wage_from", precision: nil
    t.datetime "wage_to", precision: nil
    t.datetime "payment_date", precision: nil
    t.decimal "salary", precision: 9, scale: 2
    t.decimal "addition", precision: 9, scale: 2
    t.decimal "discount", precision: 9, scale: 2
    t.decimal "tax", precision: 9, scale: 2
    t.decimal "payroll_tax", precision: 9, scale: 2
    t.decimal "amount", precision: 9, scale: 2
    t.integer "organization_id"
    t.integer "accounting_period_id"
    t.integer "wage_period_id"
    t.integer "employee_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "warehouses", id: :serial, force: :cascade do |t|
    t.integer "organization_id"
    t.string "name", limit: 255
    t.integer "primary_contact_id"
    t.string "address", limit: 255
    t.string "zip", limit: 255
    t.string "city", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name", "organization_id"], name: "index_warehouses_on_name_and_organization_id", unique: true
  end

end
