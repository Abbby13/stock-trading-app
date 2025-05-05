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

ActiveRecord::Schema[8.0].define(version: 2025_05_03_061952) do
  ActiveRecord::Schema[8.0].define(version: 2025_05_03_010212) do
  ActiveRecord::Schema[8.0].define(version: 2025_05_03_015949) do
    # These are extensions that must be enabled in order to support this database
    enable_extension "pg_catalog.plpgsql"
  
    create_table "portfolio_stocks", force: :cascade do |t|
      t.bigint "portfolio_id", null: false
      t.bigint "stock_id", null: false
      t.integer "quantity"
      t.decimal "avg_price"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["portfolio_id"], name: "index_portfolio_stocks_on_portfolio_id"
      t.index ["stock_id"], name: "index_portfolio_stocks_on_stock_id"
    end
  
    create_table "portfolios", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.decimal "cash_balance", precision: 15, scale: 2, default: "0.0", null: false
      t.index ["user_id"], name: "index_portfolios_on_user_id"
    end
  
    create_table "stocks", force: :cascade do |t|
      t.string "symbol"
      t.string "company_name"
      t.decimal "current_price"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  
    create_table "transactions", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.bigint "stock_id", null: false
      t.string "transaction_type"
      t.integer "quantity"
      t.decimal "price"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["stock_id"], name: "index_transactions_on_stock_id"
      t.index ["user_id"], name: "index_transactions_on_user_id"
    end
  
    create_table "users", force: :cascade do |t|
      t.string "email"
      t.string "password_digest"
      t.string "role"
      t.boolean "approved"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "approved_at"
    end
  
    add_foreign_key "portfolio_stocks", "portfolios"
    add_foreign_key "portfolio_stocks", "stocks"
    add_foreign_key "portfolios", "users"
    add_foreign_key "transactions", "stocks"
    add_foreign_key "transactions", "users"
  end