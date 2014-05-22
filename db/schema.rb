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

ActiveRecord::Schema.define(version: 20140512152302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.text     "body"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.string   "parent_type"
    t.integer  "parent_id"
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

  create_table "customers", force: true do |t|
    t.string   "address"
    t.string   "city"
    t.string   "vat_number"
    t.string   "name"
    t.string   "zip"
    t.boolean  "reseller"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manuals", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_transactions", force: true do |t|
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "product_id"
    t.integer  "warehouse_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "comment"
    t.string   "product_type",       default: "refined"
    t.integer  "in_price"
    t.integer  "distributor_price"
    t.integer  "retail_price"
    t.integer  "vat"
    t.string   "unit"
    t.string   "weight"
    t.string   "package_dimensions"
    t.datetime "expire_at"
    t.datetime "refined_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sale_items", force: true do |t|
    t.integer  "sale_id"
    t.integer  "product_id"
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
    t.string   "contact_email"
    t.string   "contact_name"
    t.string   "state"
    t.string   "goods_state"
    t.string   "money_state"
    t.datetime "approved_at"
    t.datetime "goods_delivered_at"
    t.datetime "paid_at"
    t.datetime "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shelves", force: true do |t|
    t.integer  "quantity",     default: 0
    t.integer  "warehouse_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suppliers", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.string   "bg_number"
    t.string   "vat_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transfers", force: true do |t|
    t.integer  "from_warehouse_id"
    t.integer  "to_warehouse_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.integer  "user_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "warehouses", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
