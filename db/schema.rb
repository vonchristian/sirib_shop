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

ActiveRecord::Schema[8.1].define(version: 2026_08_03_120047) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "account_type", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.bigint "ledger_id", null: false
    t.string "name", null: false
    t.integer "normal_balance", default: 0, null: false
    t.bigint "parent_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["ledger_id", "code"], name: "index_accounts_on_ledger_id_and_code", unique: true
    t.index ["ledger_id"], name: "index_accounts_on_ledger_id"
    t.index ["parent_id"], name: "index_accounts_on_parent_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "businesses", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "PHP", null: false
    t.string "email"
    t.string "legal_name"
    t.string "name", null: false
    t.string "phone"
    t.integer "status", default: 0, null: false
    t.string "tax_identifier"
    t.string "timezone", default: "Asia/Manila", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_businesses_on_code", unique: true
  end

  create_table "cart_lines", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, default: "1.0", null: false
    t.bigint "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_variant_id"], name: "index_cart_lines_on_cart_id_and_product_variant_id", unique: true
    t.index ["cart_id"], name: "index_cart_lines_on_cart_id"
    t.index ["product_variant_id"], name: "index_cart_lines_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id"
    t.bigint "customer_id"
    t.integer "status", default: 0, null: false
    t.bigint "store_location_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_carts_on_business_id"
    t.index ["created_by_user_id"], name: "index_carts_on_created_by_user_id"
    t.index ["customer_id"], name: "index_carts_on_customer_id"
    t.index ["store_location_id", "status"], name: "index_carts_on_store_location_id_and_status"
    t.index ["store_location_id"], name: "index_carts_on_store_location_id"
  end

  create_table "cash_movements", force: :cascade do |t|
    t.bigint "amount_cents", default: 0, null: false
    t.bigint "cash_session_id", null: false
    t.datetime "created_at", null: false
    t.integer "movement_type", null: false
    t.datetime "occurred_at", null: false
    t.bigint "reference_id"
    t.string "reference_type"
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_cash_movements_on_cash_session_id"
    t.index ["reference_type", "reference_id"], name: "index_cash_movements_on_reference_type_and_reference_id"
  end

  create_table "cash_registers", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.bigint "store_location_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "code"], name: "index_cash_registers_on_business_id_and_code", unique: true
    t.index ["business_id"], name: "index_cash_registers_on_business_id"
    t.index ["store_location_id"], name: "index_cash_registers_on_store_location_id"
  end

  create_table "cash_sessions", force: :cascade do |t|
    t.bigint "actual_closing_amount_cents"
    t.bigint "cash_register_id", null: false
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.bigint "difference_cents"
    t.bigint "expected_closing_amount_cents", default: 0, null: false
    t.datetime "opened_at", null: false
    t.bigint "opening_amount_cents", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cash_register_id", "status"], name: "index_cash_sessions_on_cash_register_id_and_status"
    t.index ["cash_register_id"], name: "index_cash_sessions_on_cash_register_id"
    t.index ["user_id"], name: "index_cash_sessions_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "code"], name: "index_categories_on_business_id_and_code", unique: true
    t.index ["business_id"], name: "index_categories_on_business_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "charges", force: :cascade do |t|
    t.bigint "amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.decimal "quantity", precision: 12, scale: 3, default: "1.0", null: false
    t.bigint "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["work_order_id"], name: "index_charges_on_work_order_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.integer "customer_type", default: 0, null: false
    t.string "email"
    t.string "name", null: false
    t.bigint "parent_id"
    t.string "phone"
    t.integer "status", default: 0, null: false
    t.string "tax_identifier"
    t.datetime "updated_at", null: false
    t.index ["business_id", "code"], name: "index_customers_on_business_id_and_code", unique: true
    t.index ["business_id"], name: "index_customers_on_business_id"
    t.index ["parent_id"], name: "index_customers_on_parent_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "imei_1"
    t.string "imei_2"
    t.bigint "product_variant_id", null: false
    t.datetime "received_at"
    t.string "serial_number"
    t.datetime "sold_at"
    t.integer "status", default: 0, null: false
    t.bigint "stock_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "imei_1"], name: "index_inventory_items_on_business_id_and_imei_1", unique: true
    t.index ["business_id", "serial_number"], name: "index_inventory_items_on_business_id_and_serial_number", unique: true
    t.index ["business_id"], name: "index_inventory_items_on_business_id"
    t.index ["product_variant_id"], name: "index_inventory_items_on_product_variant_id"
    t.index ["stock_id", "status"], name: "index_inventory_items_on_stock_id_and_status"
    t.index ["stock_id"], name: "index_inventory_items_on_stock_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "entry_number", null: false
    t.bigint "ledger_id", null: false
    t.datetime "occurred_at", null: false
    t.datetime "posted_at"
    t.bigint "reference_id"
    t.string "reference_type"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["ledger_id", "entry_number"], name: "index_journal_entries_on_ledger_id_and_entry_number", unique: true
    t.index ["ledger_id"], name: "index_journal_entries_on_ledger_id"
  end

  create_table "journal_lines", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.bigint "credit_cents", default: 0, null: false
    t.bigint "debit_cents", default: 0, null: false
    t.string "description"
    t.bigint "journal_entry_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_journal_lines_on_account_id"
    t.index ["journal_entry_id", "account_id"], name: "index_journal_lines_on_journal_entry_id_and_account_id"
    t.index ["journal_entry_id"], name: "index_journal_lines_on_journal_entry_id"
  end

  create_table "ledgers", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "code"], name: "index_ledgers_on_business_id_and_code", unique: true
    t.index ["business_id"], name: "index_ledgers_on_business_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.integer "movement_type", null: false
    t.datetime "occurred_at", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.bigint "reference_id"
    t.string "reference_type"
    t.bigint "stock_id", null: false
    t.bigint "unit_cost_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_line_items_on_business_id"
    t.index ["reference_type", "reference_id"], name: "index_line_items_on_reference_type_and_reference_id"
    t.index ["stock_id", "occurred_at"], name: "index_line_items_on_stock_id_and_occurred_at"
    t.index ["stock_id"], name: "index_line_items_on_stock_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "amount_cents", default: 0, null: false
    t.bigint "business_id", null: false
    t.bigint "cash_session_id"
    t.datetime "created_at", null: false
    t.datetime "paid_at", null: false
    t.integer "payment_method", default: 0, null: false
    t.string "reference"
    t.bigint "sales_order_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_payments_on_business_id"
    t.index ["cash_session_id"], name: "index_payments_on_cash_session_id"
    t.index ["sales_order_id", "status"], name: "index_payments_on_sales_order_id_and_status"
    t.index ["sales_order_id"], name: "index_payments_on_sales_order_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "barcode"
    t.bigint "business_id", null: false
    t.bigint "cost_price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "product_id", null: false
    t.bigint "selling_price_cents", default: 0, null: false
    t.string "sku", null: false
    t.integer "status", default: 0, null: false
    t.boolean "track_serial", default: false, null: false
    t.string "unit", default: "pcs", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "sku"], name: "index_product_variants_on_business_id_and_sku", unique: true
    t.index ["business_id"], name: "index_product_variants_on_business_id"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "brand"
    t.bigint "business_id", null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "name"], name: "index_products_on_business_id_and_name"
    t.index ["business_id"], name: "index_products_on_business_id"
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "purchase_order_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.bigint "purchase_order_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.decimal "received_quantity", precision: 12, scale: 3, default: "0.0", null: false
    t.bigint "tax_cents", default: 0, null: false
    t.bigint "total_cents", default: 0, null: false
    t.bigint "unit_cost_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_purchase_order_lines_on_product_variant_id"
    t.index ["purchase_order_id", "product_variant_id"], name: "idx_on_purchase_order_id_product_variant_id_52245d0e64"
    t.index ["purchase_order_id"], name: "index_purchase_order_lines_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id"
    t.bigint "destination_store_location_id", null: false
    t.string "number", null: false
    t.datetime "ordered_at", null: false
    t.integer "status", default: 0, null: false
    t.bigint "subtotal_cents", default: 0, null: false
    t.bigint "supplier_id", null: false
    t.bigint "tax_total_cents", default: 0, null: false
    t.bigint "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "number"], name: "index_purchase_orders_on_business_id_and_number", unique: true
    t.index ["business_id"], name: "index_purchase_orders_on_business_id"
    t.index ["created_by_user_id"], name: "index_purchase_orders_on_created_by_user_id"
    t.index ["destination_store_location_id"], name: "index_purchase_orders_on_destination_store_location_id"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
  end

  create_table "purchase_return_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.bigint "purchase_return_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.bigint "unit_cost_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_purchase_return_lines_on_product_variant_id"
    t.index ["purchase_return_id", "product_variant_id"], name: "idx_on_purchase_return_id_product_variant_id_89976d4a29"
    t.index ["purchase_return_id"], name: "index_purchase_return_lines_on_purchase_return_id"
  end

  create_table "purchase_returns", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "number", null: false
    t.bigint "purchase_order_id", null: false
    t.text "reason"
    t.integer "status", default: 0, null: false
    t.bigint "store_location_id", null: false
    t.bigint "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "number"], name: "index_purchase_returns_on_business_id_and_number", unique: true
    t.index ["business_id"], name: "index_purchase_returns_on_business_id"
    t.index ["purchase_order_id"], name: "index_purchase_returns_on_purchase_order_id"
    t.index ["store_location_id"], name: "index_purchase_returns_on_store_location_id"
    t.index ["supplier_id"], name: "index_purchase_returns_on_supplier_id"
  end

  create_table "sales_order_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "discount_cents", default: 0, null: false
    t.bigint "product_variant_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.bigint "sales_order_id", null: false
    t.bigint "tax_cents", default: 0, null: false
    t.bigint "total_cents", default: 0, null: false
    t.bigint "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_sales_order_lines_on_product_variant_id"
    t.index ["sales_order_id"], name: "index_sales_order_lines_on_sales_order_id"
  end

  create_table "sales_orders", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id"
    t.bigint "customer_id"
    t.bigint "discount_total_cents", default: 0, null: false
    t.datetime "fulfilled_at"
    t.string "number", null: false
    t.datetime "ordered_at", null: false
    t.integer "status", default: 0, null: false
    t.bigint "store_location_id", null: false
    t.bigint "subtotal_cents", default: 0, null: false
    t.bigint "tax_total_cents", default: 0, null: false
    t.bigint "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "number"], name: "index_sales_orders_on_business_id_and_number", unique: true
    t.index ["business_id"], name: "index_sales_orders_on_business_id"
    t.index ["created_by_user_id"], name: "index_sales_orders_on_created_by_user_id"
    t.index ["customer_id"], name: "index_sales_orders_on_customer_id"
    t.index ["store_location_id", "ordered_at"], name: "index_sales_orders_on_store_location_id_and_ordered_at"
    t.index ["store_location_id"], name: "index_sales_orders_on_store_location_id"
  end

  create_table "sales_return_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.bigint "sales_return_id", null: false
    t.bigint "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_sales_return_lines_on_product_variant_id"
    t.index ["sales_return_id", "product_variant_id"], name: "idx_on_sales_return_id_product_variant_id_04e5ab9c4e"
    t.index ["sales_return_id"], name: "index_sales_return_lines_on_sales_return_id"
  end

  create_table "sales_returns", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.string "number", null: false
    t.text "reason"
    t.bigint "sales_order_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "store_location_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "number"], name: "index_sales_returns_on_business_id_and_number", unique: true
    t.index ["business_id"], name: "index_sales_returns_on_business_id"
    t.index ["customer_id"], name: "index_sales_returns_on_customer_id"
    t.index ["sales_order_id"], name: "index_sales_returns_on_sales_order_id"
    t.index ["store_location_id"], name: "index_sales_returns_on_store_location_id"
  end

  create_table "service_asset_categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "name"], name: "index_service_asset_categories_on_business_id_and_name", unique: true
    t.index ["business_id"], name: "index_service_asset_categories_on_business_id"
  end

  create_table "service_asset_fields", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "data_type", default: 0, null: false
    t.string "label", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.bigint "service_asset_category_id", null: false
    t.boolean "unique", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["service_asset_category_id", "name"], name: "idx_on_service_asset_category_id_name_f40b3cafb3", unique: true
    t.index ["service_asset_category_id", "position"], name: "idx_on_service_asset_category_id_position_e59b0163f3"
    t.index ["service_asset_category_id"], name: "index_service_asset_fields_on_service_asset_category_id"
  end

  create_table "service_asset_values", force: :cascade do |t|
    t.boolean "boolean_value"
    t.datetime "created_at", null: false
    t.date "date_value"
    t.decimal "decimal_value", precision: 12, scale: 2
    t.bigint "integer_value"
    t.bigint "service_asset_field_id", null: false
    t.bigint "service_asset_id", null: false
    t.string "text_value"
    t.datetime "updated_at", null: false
    t.index ["service_asset_field_id"], name: "index_service_asset_values_on_service_asset_field_id"
    t.index ["service_asset_id", "service_asset_field_id"], name: "index_sav_on_asset_and_field", unique: true
    t.index ["service_asset_id"], name: "index_service_asset_values_on_service_asset_id"
  end

  create_table "service_assets", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "name", null: false
    t.bigint "service_asset_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "name"], name: "index_service_assets_on_business_id_and_name"
    t.index ["business_id"], name: "index_service_assets_on_business_id"
    t.index ["customer_id", "service_asset_category_id"], name: "idx_on_customer_id_service_asset_category_id_c9daf465f4"
    t.index ["customer_id"], name: "index_service_assets_on_customer_id"
    t.index ["service_asset_category_id"], name: "index_service_assets_on_service_asset_category_id"
  end

  create_table "service_items", force: :cascade do |t|
    t.integer "condition", default: 0, null: false
    t.integer "condition_at_return"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.text "notes"
    t.decimal "quantity", precision: 12, scale: 3, default: "1.0", null: false
    t.datetime "received_at", null: false
    t.datetime "returned_at"
    t.bigint "returned_by_user_id"
    t.string "serial_number"
    t.string "tag_number", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["returned_by_user_id"], name: "index_service_items_on_returned_by_user_id"
    t.index ["work_order_id", "returned_at"], name: "index_service_items_on_work_order_id_and_returned_at"
    t.index ["work_order_id", "tag_number"], name: "index_service_items_on_work_order_id_and_tag_number", unique: true
    t.index ["work_order_id"], name: "index_service_items_on_work_order_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, default: "0.0", null: false
    t.decimal "reserved_quantity", precision: 12, scale: 3, default: "0.0", null: false
    t.bigint "store_location_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_stocks_on_business_id"
    t.index ["product_variant_id"], name: "index_stocks_on_product_variant_id"
    t.index ["store_location_id", "product_variant_id"], name: "index_stocks_on_store_location_id_and_product_variant_id", unique: true
    t.index ["store_location_id"], name: "index_stocks_on_store_location_id"
  end

  create_table "store_locations", force: :cascade do |t|
    t.string "address"
    t.bigint "business_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.boolean "is_main", default: false, null: false
    t.integer "location_type", default: 0, null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "code"], name: "index_store_locations_on_business_id_and_code", unique: true
    t.index ["business_id"], name: "index_store_locations_on_business_active_main", unique: true, where: "((is_main = true) AND (status = 0))"
    t.index ["business_id"], name: "index_store_locations_on_business_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.string "phone"
    t.integer "status", default: 0, null: false
    t.integer "supplier_type", default: 0, null: false
    t.string "tax_identifier"
    t.datetime "updated_at", null: false
    t.index ["business_id", "code"], name: "index_suppliers_on_business_id_and_code", unique: true
    t.index ["business_id"], name: "index_suppliers_on_business_id"
  end

  create_table "transfer_order_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.decimal "received_quantity", precision: 12, scale: 3, default: "0.0", null: false
    t.bigint "transfer_order_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_transfer_order_lines_on_product_variant_id"
    t.index ["transfer_order_id", "product_variant_id"], name: "idx_on_transfer_order_id_product_variant_id_329443060c"
    t.index ["transfer_order_id"], name: "index_transfer_order_lines_on_transfer_order_id"
  end

  create_table "transfer_orders", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "business_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "created_by_user_id"
    t.bigint "destination_store_location_id", null: false
    t.string "number", null: false
    t.bigint "origin_store_location_id", null: false
    t.datetime "received_at"
    t.datetime "requested_at"
    t.datetime "shipped_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "number"], name: "index_transfer_orders_on_business_id_and_number", unique: true
    t.index ["business_id"], name: "index_transfer_orders_on_business_id"
    t.index ["created_by_user_id"], name: "index_transfer_orders_on_created_by_user_id"
    t.index ["destination_store_location_id"], name: "index_transfer_orders_on_destination_store_location_id"
    t.index ["origin_store_location_id", "status"], name: "index_transfer_orders_on_origin_store_location_id_and_status"
    t.index ["origin_store_location_id"], name: "index_transfer_orders_on_origin_store_location_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "email"], name: "index_users_on_business_id_and_email", unique: true
    t.index ["business_id"], name: "index_users_on_business_id"
  end

  create_table "work_order_parts", force: :cascade do |t|
    t.boolean "consumed", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "product_variant_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, default: "1.0", null: false
    t.bigint "stock_id"
    t.bigint "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["product_variant_id"], name: "index_work_order_parts_on_product_variant_id"
    t.index ["stock_id"], name: "index_work_order_parts_on_stock_id"
    t.index ["work_order_id"], name: "index_work_order_parts_on_work_order_id"
  end

  create_table "work_order_services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.decimal "quantity", precision: 12, scale: 3, default: "1.0", null: false
    t.bigint "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["work_order_id"], name: "index_work_order_services_on_work_order_id"
  end

  create_table "work_order_tasks", force: :cascade do |t|
    t.integer "actual_minutes"
    t.bigint "assigned_user_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "estimated_minutes"
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["assigned_user_id"], name: "index_work_order_tasks_on_assigned_user_id"
    t.index ["work_order_id", "status"], name: "index_work_order_tasks_on_work_order_id_and_status"
    t.index ["work_order_id"], name: "index_work_order_tasks_on_work_order_id"
  end

  create_table "work_orders", force: :cascade do |t|
    t.bigint "assigned_user_id"
    t.bigint "business_id", null: false
    t.datetime "closed_at"
    t.text "complaint"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "diagnosis"
    t.text "notes"
    t.string "number", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "promised_at"
    t.datetime "received_at", null: false
    t.bigint "service_asset_id", null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.bigint "store_location_id", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_work_orders_on_assigned_user_id"
    t.index ["business_id", "number"], name: "index_work_orders_on_business_id_and_number", unique: true
    t.index ["business_id", "service_asset_id"], name: "index_work_orders_on_business_id_and_service_asset_id"
    t.index ["business_id", "status"], name: "index_work_orders_on_business_id_and_status"
    t.index ["business_id"], name: "index_work_orders_on_business_id"
    t.index ["customer_id"], name: "index_work_orders_on_customer_id"
    t.index ["service_asset_id"], name: "index_work_orders_on_service_asset_id"
    t.index ["store_location_id", "status"], name: "index_work_orders_on_store_location_id_and_status"
    t.index ["store_location_id"], name: "index_work_orders_on_store_location_id"
  end

  add_foreign_key "accounts", "accounts", column: "parent_id"
  add_foreign_key "accounts", "ledgers"
  add_foreign_key "cart_lines", "carts"
  add_foreign_key "cart_lines", "product_variants"
  add_foreign_key "carts", "businesses"
  add_foreign_key "carts", "customers"
  add_foreign_key "carts", "store_locations"
  add_foreign_key "carts", "users", column: "created_by_user_id"
  add_foreign_key "cash_movements", "cash_sessions"
  add_foreign_key "cash_registers", "businesses"
  add_foreign_key "cash_registers", "store_locations"
  add_foreign_key "cash_sessions", "cash_registers"
  add_foreign_key "cash_sessions", "users"
  add_foreign_key "categories", "businesses"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "charges", "work_orders"
  add_foreign_key "customers", "businesses"
  add_foreign_key "customers", "customers", column: "parent_id"
  add_foreign_key "inventory_items", "businesses"
  add_foreign_key "inventory_items", "product_variants"
  add_foreign_key "inventory_items", "stocks"
  add_foreign_key "journal_entries", "ledgers"
  add_foreign_key "journal_lines", "accounts"
  add_foreign_key "journal_lines", "journal_entries"
  add_foreign_key "ledgers", "businesses"
  add_foreign_key "line_items", "businesses"
  add_foreign_key "line_items", "stocks"
  add_foreign_key "payments", "businesses"
  add_foreign_key "payments", "cash_sessions"
  add_foreign_key "payments", "sales_orders"
  add_foreign_key "product_variants", "businesses"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "businesses"
  add_foreign_key "products", "categories"
  add_foreign_key "purchase_order_lines", "product_variants"
  add_foreign_key "purchase_order_lines", "purchase_orders"
  add_foreign_key "purchase_orders", "businesses"
  add_foreign_key "purchase_orders", "store_locations", column: "destination_store_location_id"
  add_foreign_key "purchase_orders", "suppliers"
  add_foreign_key "purchase_orders", "users", column: "created_by_user_id"
  add_foreign_key "purchase_return_lines", "product_variants"
  add_foreign_key "purchase_return_lines", "purchase_returns"
  add_foreign_key "purchase_returns", "businesses"
  add_foreign_key "purchase_returns", "purchase_orders"
  add_foreign_key "purchase_returns", "store_locations"
  add_foreign_key "purchase_returns", "suppliers"
  add_foreign_key "sales_order_lines", "product_variants"
  add_foreign_key "sales_order_lines", "sales_orders"
  add_foreign_key "sales_orders", "businesses"
  add_foreign_key "sales_orders", "customers"
  add_foreign_key "sales_orders", "store_locations"
  add_foreign_key "sales_orders", "users", column: "created_by_user_id"
  add_foreign_key "sales_return_lines", "product_variants"
  add_foreign_key "sales_return_lines", "sales_returns"
  add_foreign_key "sales_returns", "businesses"
  add_foreign_key "sales_returns", "customers"
  add_foreign_key "sales_returns", "sales_orders"
  add_foreign_key "sales_returns", "store_locations"
  add_foreign_key "service_asset_categories", "businesses"
  add_foreign_key "service_asset_fields", "service_asset_categories"
  add_foreign_key "service_asset_values", "service_asset_fields"
  add_foreign_key "service_asset_values", "service_assets"
  add_foreign_key "service_assets", "businesses"
  add_foreign_key "service_assets", "customers"
  add_foreign_key "service_assets", "service_asset_categories"
  add_foreign_key "service_items", "users", column: "returned_by_user_id"
  add_foreign_key "service_items", "work_orders"
  add_foreign_key "stocks", "businesses"
  add_foreign_key "stocks", "product_variants"
  add_foreign_key "stocks", "store_locations"
  add_foreign_key "store_locations", "businesses"
  add_foreign_key "suppliers", "businesses"
  add_foreign_key "transfer_order_lines", "product_variants"
  add_foreign_key "transfer_order_lines", "transfer_orders"
  add_foreign_key "transfer_orders", "businesses"
  add_foreign_key "transfer_orders", "store_locations", column: "destination_store_location_id"
  add_foreign_key "transfer_orders", "store_locations", column: "origin_store_location_id"
  add_foreign_key "transfer_orders", "users", column: "created_by_user_id"
  add_foreign_key "users", "businesses"
  add_foreign_key "work_order_parts", "product_variants"
  add_foreign_key "work_order_parts", "stocks"
  add_foreign_key "work_order_parts", "work_orders"
  add_foreign_key "work_order_services", "work_orders"
  add_foreign_key "work_order_tasks", "users", column: "assigned_user_id"
  add_foreign_key "work_order_tasks", "work_orders"
  add_foreign_key "work_orders", "businesses"
  add_foreign_key "work_orders", "customers"
  add_foreign_key "work_orders", "service_assets"
  add_foreign_key "work_orders", "store_locations"
  add_foreign_key "work_orders", "users", column: "assigned_user_id"
end
