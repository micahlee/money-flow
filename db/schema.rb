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

ActiveRecord::Schema.define(version: 2021_05_04_151432) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "orafce"
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "accounts", force: :cascade do |t|
    t.bigint "connection_id"
    t.string "account_id"
    t.decimal "balance_current"
    t.decimal "balance_available"
    t.string "iso_currency_code"
    t.string "name"
    t.string "official_name"
    t.string "account_type"
    t.string "account_subtype"
    t.string "mask"
    t.boolean "archived", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden_from_snapshot", default: false
    t.datetime "last_synced_at"
    t.datetime "last_sync_error_at"
    t.text "last_sync_error"
    t.boolean "exclude_from_available", default: false
    t.string "payment_link"
    t.index ["account_id"], name: "index_accounts_on_account_id"
    t.index ["connection_id"], name: "index_accounts_on_connection_id"
  end

  create_table "connections", force: :cascade do |t|
    t.string "name"
    t.string "access_token"
    t.string "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: true, null: false
  end

  create_table "funds", force: :cascade do |t|
    t.string "name"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_clear", default: false
    t.index ["account_id"], name: "index_funds_on_account_id"
  end

  create_table "promotional_transactions", force: :cascade do |t|
    t.bigint "transaction_id"
    t.date "due"
    t.index ["transaction_id"], name: "index_promotional_transactions_on_transaction_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id"
    t.decimal "amount"
    t.string "category"
    t.string "category_id"
    t.string "date"
    t.string "iso_currency_code"
    t.string "name"
    t.boolean "pending"
    t.string "transaction_id"
    t.string "transaction_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cleared", default: false
    t.bigint "fund_id"
    t.bigint "split_from_id"
    t.text "note"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["fund_id"], name: "index_transactions_on_fund_id"
    t.index ["split_from_id"], name: "index_transactions_on_split_from_id"
  end

  add_foreign_key "accounts", "connections"
  add_foreign_key "funds", "accounts"
  add_foreign_key "promotional_transactions", "transactions"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "funds"
  add_foreign_key "transactions", "transactions", column: "split_from_id"
end
