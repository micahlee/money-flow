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

ActiveRecord::Schema.define(version: 2021_09_16_173523) do

  # These are extensions that must be enabled in order to support this database
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
    t.bigint "family_id", null: false
    t.index ["family_id"], name: "index_connections_on_family_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "classifier_data"
    t.text "money_mover_yaml"
  end

  create_table "families_users", id: false, force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "user_id", null: false
    t.index ["family_id", "user_id"], name: "index_families_users_on_family_id_and_user_id"
  end

  create_table "funds", force: :cascade do |t|
    t.string "name"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_clear", default: false
    t.boolean "micah"
    t.boolean "carrie"
    t.bigint "family_id", null: false
    t.index ["account_id"], name: "index_funds_on_account_id"
    t.index ["family_id"], name: "index_funds_on_family_id"
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

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "accounts", "connections"
  add_foreign_key "funds", "accounts"
  add_foreign_key "promotional_transactions", "transactions"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "funds"
  add_foreign_key "transactions", "transactions", column: "split_from_id"
end
