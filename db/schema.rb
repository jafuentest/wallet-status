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

ActiveRecord::Schema[7.0].define(version: 2022_03_28_052750) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "positions", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.string "sub_wallet"
    t.decimal "cost_basis"
    t.decimal "amount", null: false
    t.string "symbol", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_positions_on_wallet_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.string "from_asset"
    t.decimal "from_amount"
    t.decimal "from_cost_basis"
    t.string "to_asset"
    t.decimal "to_amount"
    t.decimal "to_cost_basis"
    t.string "fee_asset"
    t.decimal "fee_amount"
    t.decimal "fee_cost_basis"
    t.string "order_id"
    t.string "order_type", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "order_type"], name: "index_transactions_on_order_id_and_order_type", unique: true
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "service", null: false
    t.string "wallet_type", null: false
    t.string "address"
    t.hstore "api_details", default: {}, null: false
    t.string "api_key"
    t.string "api_secret"
    t.datetime "last_sync"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "positions", "wallets"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "wallets", "users"
end
