FactoryBot.define do
  factory :business do
    sequence(:name) { |n| "Test Shop #{n}" }
    sequence(:code) { |n| "BIZ-#{n}-#{SecureRandom.hex(3)}" }
    timezone { "Asia/Manila" }
    currency { "PHP" }
    status { :active }
  end

  factory :admin_user do
    sequence(:name) { |n| "Admin #{n}" }
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { "password123" }
    status { :active }
  end

  factory :user do
    business
    sequence(:name) { |n| "Manager #{n}" }
    sequence(:email) { |n| "manager#{n}@example.com" }
    password { "password123" }
    status { :active }
  end

  factory :store_location do
    business
    sequence(:name) { |n| "Store #{n}" }
    sequence(:code) { |n| "LOC-#{n}" }
    location_type { :store }
    is_main { false }
    status { :active }
  end

  factory :customer do
    business
    sequence(:name) { |n| "Customer #{n}" }
    customer_type { :individual }
    status { :active }
  end

  factory :supplier do
    business
    sequence(:name) { |n| "Supplier #{n}" }
    supplier_type { :wholesale }
    status { :active }
  end

  factory :category do
    business
    sequence(:name) { |n| "Category #{n}" }
    status { :active }
  end

  factory :product do
    business
    sequence(:name) { |n| "Product #{n}" }
    status { :active }
  end

  factory :product_variant do
    business
    product
    sequence(:name) { |n| "Variant #{n}" }
    sequence(:sku) { |n| "SKU-#{n}-#{SecureRandom.hex(3)}" }
    cost_price_cents { 1000_00 }
    selling_price_cents { 1200_00 }
    track_serial { false }
    status { :active }
  end

  factory :stock do
    business
    store_location
    product_variant
    quantity { 10 }
    reserved_quantity { 0 }
  end

  factory :inventory_item do
    business
    stock
    product_variant
    status { :available }
    received_at { Time.current }
  end

  factory :cart do
    business
    store_location
    status { :open }
  end

  factory :cart_line do
    cart
    product_variant
    quantity { 1 }
    unit_price_cents { 1200_00 }
  end

  factory :sales_order do
    business
    store_location
    sequence(:number) { |n| "SO-#{Date.today.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    ordered_at { Time.current }
    subtotal_cents { 0 }
    discount_total_cents { 0 }
    tax_total_cents { 0 }
    total_cents { 0 }
    status { :draft }
  end

  factory :sales_order_line do
    sales_order
    product_variant
    quantity { 1 }
    unit_price_cents { 1200_00 }
    discount_cents { 0 }
    tax_cents { 0 }
    total_cents { 1200_00 }
  end

  factory :payment do
    business
    sales_order
    payment_method { :cash }
    status { :completed }
    amount_cents { 100 }
    paid_at { Time.current }
  end

  factory :sales_return do
    business
    sales_order
    store_location
    sequence(:number) { |n| "SR-#{Date.today.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    status { :open }
  end

  factory :sales_return_line do
    sales_return
    product_variant
    quantity { 1 }
    unit_price_cents { 1200_00 }
  end

  factory :purchase_order do
    business
    supplier
    destination_store_location { association :store_location, business: business, is_main: true }
    sequence(:number) { |n| "PO-#{Date.today.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    ordered_at { Time.current }
    status { :draft }
  end

  factory :purchase_order_line do
    purchase_order
    product_variant
    quantity { 10 }
    unit_cost_cents { 800_00 }
    received_quantity { 0 }
  end

  factory :purchase_return do
    business
    purchase_order
    supplier
    store_location
    sequence(:number) { |n| "PR-#{Date.today.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    status { :open }
  end

  factory :purchase_return_line do
    purchase_return
    product_variant
    quantity { 1 }
    unit_cost_cents { 800_00 }
  end

  factory :transfer_order do
    business
    origin_store_location { association :store_location, business: business }
    destination_store_location { association :store_location, business: business }
    sequence(:number) { |n| "TO-#{Date.today.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    status { :draft }
  end

  factory :transfer_order_line do
    transfer_order
    product_variant
    quantity { 5 }
    received_quantity { 0 }
  end

  factory :ledger do
    business
    sequence(:name) { |n| "Ledger #{n}" }
    sequence(:code) { |n| "LG-#{n}" }
    status { :active }
  end

  factory :account do
    ledger
    sequence(:code) { |n| "1#{format('%03d', n)}" }
    sequence(:name) { |n| "Account #{n}" }
    account_type { :asset }
    normal_balance { :debit }
    status { :active }
  end

  factory :journal_entry do
    ledger
    sequence(:entry_number) { |n| "JE-#{Date.today.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    occurred_at { Time.current }
    status { :draft }
  end

  factory :journal_line do
    journal_entry
    account
    debit_cents { 0 }
    credit_cents { 0 }
  end

  factory :cash_register do
    business
    store_location
    sequence(:name) { |n| "Register #{n}" }
    sequence(:code) { |n| "REG-#{n}" }
    status { :active }
  end

  factory :cash_session do
    cash_register
    user
    status { :open }
    opened_at { Time.current }
    opening_amount_cents { 0 }
  end

  factory :cash_movement do
    cash_session
    movement_type { :sale }
    amount_cents { 100 }
    occurred_at { Time.current }
  end

  factory :service_asset_category do
    business
    sequence(:name) { |n| "Category #{n}" }
    active { true }
  end

  factory :service_asset_field do
    service_asset_category
    sequence(:name) { |n| "field_#{n}" }
    sequence(:label) { |n| "Field #{n}" }
    data_type { :text }
    required { false }
    active { true }
  end

  factory :service_asset do
    business
    customer
    service_asset_category
    sequence(:name) { |n| "Asset #{n}" }
  end

  factory :service_asset_value do
    service_asset
    service_asset_field
  end

  factory :work_order do
    business
    store_location
    customer
    service_asset
    sequence(:number) { |n| "WO-#{Date.today.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    status { :received }
    priority { :normal }
    received_at { Time.current }
  end

  factory :work_order_task do
    work_order
    sequence(:description) { |n| "Task #{n}" }
    status { :pending }
  end

  factory :work_order_part do
    work_order
    product_variant
    quantity { 1 }
    unit_price_cents { 500_00 }
  end

  factory :work_order_service do
    work_order
    sequence(:name) { |n| "Service #{n}" }
    quantity { 1 }
    unit_price_cents { 1000_00 }
  end

  factory :charge do
    work_order
    sequence(:description) { |n| "Charge #{n}" }
    quantity { 1 }
    unit_price_cents { 1000_00 }
    amount_cents { 1000_00 }
  end

  factory :service_item do
    work_order
    sequence(:tag_number) { |n| "WO-#{n}-01" }
    sequence(:name) { |n| "Item #{n}" }
    condition { :good }
    quantity { 1 }
    received_at { Time.current }
  end

  factory :line_item do
    business
    stock
    movement_type { :purchase }
    quantity { 1 }
    unit_cost_cents { 100 }
    occurred_at { Time.current }
  end
end
