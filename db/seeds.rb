# Idempotent demo seed data for CellShop.
#   bin/rails db:seed

if AdminUser.find_by(email: "admin@cellshop.example").nil?
  AdminUser.create!(
    name: "Platform Admin",
    email: "admin@cellshop.example",
    password: "password123",
    status: :active
  )
  puts "Created admin@cellshop.example / password123"
end

business = Business.find_by(code: "DEMO")
if business.nil?
  business = Business.create!(
    name: "Sirib Cell Shop",
    legal_name: "Sirib Cell Shop Trading",
    code: "DEMO",
    email: "owner@cellshop.example",
    phone: "+63 912 345 6789",
    tax_identifier: "123-456-789-000",
    timezone: "Asia/Manila",
    currency: "PHP",
    status: :active
  )
  puts "Created business DEMO (Sirib Cell Shop)"
end

Current.user = nil

main = business.store_locations.find_by(code: "MAIN")
if main.nil?
  main = business.store_locations.create!(
    name: "Main Store",
    code: "MAIN",
    location_type: :store,
    is_main: true,
    address: "123 Rizal Ave, Cebu City",
    status: :active
  )
  puts "Created Main Store"
end

branch = business.store_locations.find_by(code: "BR-01")
if branch.nil?
  branch = business.store_locations.create!(
    name: "Ayala Branch",
    code: "BR-01",
    location_type: :store,
    is_main: false,
    address: "Ayala Center Cebu, Cebu City",
    status: :active
  )
  puts "Created Ayala Branch"
end

[{ name: "Manager", email: "manager@cellshop.example" },
 { name: "Cashier", email: "cashier@cellshop.example" },
 { name: "Technician", email: "tech@cellshop.example" }].each do |u|
  if business.users.find_by(email: u[:email]).nil?
    business.users.create!(name: u[:name], email: u[:email], password: "password123", status: :active)
    puts "Created user #{u[:email]} / password123"
  end
end

if business.customers.where(name: "Juan Dela Cruz").none?
  business.customers.create!(name: "Juan Dela Cruz", customer_type: :individual, code: "C-0001", email: "juan@example.com", phone: "09171234567", status: :active)
end
if business.customers.where(name: "Maria Santos").none?
  business.customers.create!(name: "Maria Santos", customer_type: :individual, code: "C-0002", email: "maria@example.com", phone: "09181112222", status: :active)
end

if business.suppliers.where(name: "TechSource Distributors").none?
  business.suppliers.create!(name: "TechSource Distributors", supplier_type: :distributor, code: "S-0001", email: "sales@techsource.example", phone: "0287654321", tax_identifier: "987-654-321-000", status: :active)
end
if business.suppliers.where(name: "MobileParts PH").none?
  business.suppliers.create!(name: "MobileParts PH", supplier_type: :wholesale, code: "S-0002", email: "orders@mobileparts.example", phone: "0281234567", status: :active)
end

category = business.categories.find_by(code: "PHONES")
category ||= business.categories.create!(name: "Smartphones", code: "PHONES", status: :active)

if business.products.where(name: "iPhone 15 Pro").none?
  product = business.products.create!(name: "iPhone 15 Pro", category: category, status: :active)
  business.product_variants.create!(
    product: product, name: "128GB Natural Titanium", sku: "IP15P-128",
    cost_price_cents: 70_000_00, selling_price_cents: 74_999_00, track_serial: true, status: :active
  )
  puts "Created iPhone 15 Pro product"
end

iphone_variant = business.product_variants.find_by(sku: "IP15P-128")
if iphone_variant && main.stocks.where(product_variant: iphone_variant).none?
  stock = main.stocks.create!(business: business, product_variant: iphone_variant, quantity: 5, reserved_quantity: 0)
  [["356789012345678", nil, "IP15P00001"],
   ["356789012345679", nil, "IP15P00002"],
   ["356789012345680", nil, "IP15P00003"],
   ["356789012345681", nil, "IP15P00004"],
   ["356789012345682", nil, "IP15P00005"]].each do |imei, _imei2, serial|
    stock.inventory_items.create!(business: business, product_variant: iphone_variant, imei_1: imei, serial_number: serial, status: :available, received_at: Time.current)
  end
  puts "Created iPhone 15 Pro stock (serialized, 5 units)"
end

if business.products.where(name: "Samsung Galaxy S24").none?
  product = business.products.create!(name: "Samsung Galaxy S24", category: category, status: :active)
  business.product_variants.create!(
    product: product, name: "256GB Onyx Black", sku: "SGS24-256",
    cost_price_cents: 42_000_00, selling_price_cents: 45_999_00, track_serial: true, status: :active
  )
  puts "Created Samsung Galaxy S24 product"
end

samsung_variant = business.product_variants.find_by(sku: "SGS24-256")
if samsung_variant && main.stocks.where(product_variant: samsung_variant).none?
  stock = main.stocks.create!(business: business, product_variant: samsung_variant, quantity: 4, reserved_quantity: 0)
  [["354123456789001", nil, "SGS24-0001"],
   ["354123456789002", nil, "SGS24-0002"],
   ["354123456789003", nil, "SGS24-0003"],
   ["354123456789004", nil, "SGS24-0004"]].each do |imei, _imei2, serial|
    stock.inventory_items.create!(business: business, product_variant: samsung_variant, imei_1: imei, serial_number: serial, status: :available, received_at: Time.current)
  end
  puts "Created Samsung Galaxy S24 stock (serialized, 4 units)"
end

if business.products.where(name: "Tempered Glass").none?
  product = business.products.create!(name: "Tempered Glass", category: category, status: :active)
  variant = business.product_variants.create!(
    product: product, name: "Universal 0.3mm", sku: "TG-UNIV",
    cost_price_cents: 50_00, selling_price_cents: 150_00, track_serial: false, status: :active
  )
  branch.stocks.create!(business: business, product_variant: variant, quantity: 100, reserved_quantity: 0)
  puts "Created Tempered Glass (non-serialized, 100 units at branch)"
end

if business.cash_registers.where(code: "REG-MAIN").none?
  business.cash_registers.create!(name: "Main Counter", code: "REG-MAIN", store_location: main, status: :active)
  puts "Created cash register REG-MAIN"
end

if business.ledgers.where(code: "GL").none?
  AccountingMapper.create_default_ledger!(business)
  puts "Created default chart of accounts (GL)"
end

categories = {}
[
  {
    name: "Phone", description: "Smartphones and cellular devices",
    fields: [
      { name: "brand", label: "Brand", data_type: :text, required: true },
      { name: "model", label: "Model", data_type: :text, required: true },
      { name: "imei_1", label: "IMEI 1", data_type: :text },
      { name: "imei_2", label: "IMEI 2", data_type: :text },
      { name: "serial_number", label: "Serial number", data_type: :text },
      { name: "storage", label: "Storage", data_type: :text },
      { name: "color", label: "Color", data_type: :text }
    ]
  },
  {
    name: "Computer", description: "Laptops and desktops",
    fields: [
      { name: "brand", label: "Brand", data_type: :text, required: true },
      { name: "model", label: "Model", data_type: :text, required: true },
      { name: "serial_number", label: "Serial number", data_type: :text },
      { name: "processor", label: "Processor", data_type: :text },
      { name: "memory", label: "Memory", data_type: :text },
      { name: "storage", label: "Storage", data_type: :text },
      { name: "operating_system", label: "Operating system", data_type: :text }
    ]
  },
  {
    name: "Motorcycle", description: "Motorcycles and scooters",
    fields: [
      { name: "make", label: "Make", data_type: :text, required: true },
      { name: "model", label: "Model", data_type: :text, required: true },
      { name: "year", label: "Year", data_type: :integer },
      { name: "plate_number", label: "Plate number", data_type: :text },
      { name: "vin", label: "VIN", data_type: :text },
      { name: "engine_number", label: "Engine number", data_type: :text },
      { name: "color", label: "Color", data_type: :text },
      { name: "odometer", label: "Odometer", data_type: :integer }
    ]
  },
  {
    name: "Automobile", description: "Cars and vehicles",
    fields: [
      { name: "make", label: "Make", data_type: :text, required: true },
      { name: "model", label: "Model", data_type: :text, required: true },
      { name: "year", label: "Year", data_type: :integer },
      { name: "plate_number", label: "Plate number", data_type: :text },
      { name: "vin", label: "VIN", data_type: :text },
      { name: "engine_number", label: "Engine number", data_type: :text },
      { name: "color", label: "Color", data_type: :text },
      { name: "odometer", label: "Odometer", data_type: :integer }
    ]
  }
].each do |data|
  category = business.service_asset_categories.find_by(name: data[:name])
  if category.nil?
    category = business.service_asset_categories.create!(name: data[:name], description: data[:description], active: true)
    data[:fields].each_with_index do |field, i|
      category.service_asset_fields.create!(field.merge(position: i, active: true))
    end
    puts "Created service asset category #{data[:name]} (#{data[:fields].size} fields)"
  end
  categories[data[:name]] = category
end

tech = business.users.find_by(email: "tech@cellshop.example")
juan = business.customers.find_by(name: "Juan Dela Cruz")

if juan && tech && business.service_assets.where(name: "iPhone 15 Pro").none?
  phone_category = categories["Phone"]
  asset = business.service_assets.create!(customer: juan, service_asset_category: phone_category, name: "iPhone 15 Pro")

  values = {
    "brand" => "Apple",
    "model" => "iPhone 15 Pro",
    "imei_1" => "356789012345678",
    "storage" => "128GB",
    "color" => "Natural Titanium"
  }
  phone_category.service_asset_fields.active.ordered.each do |field|
    raw = values[field.name]
    next if raw.nil?

    value = asset.service_asset_values.build(service_asset_field: field)
    value.value = raw
    value.save!
  end

  puts "Created service asset iPhone 15 Pro (Juan Dela Cruz)"
end

if juan && business.work_orders.where(number: "WO-DEMO").none?
  asset = business.service_assets.find_by(name: "iPhone 15 Pro")
  main = business.store_locations.find_by(code: "MAIN")
  if asset && main
    wo = business.work_orders.create!(
      store_location: main,
      customer: juan,
      service_asset: asset,
      assigned_user: tech,
      number: "WO-DEMO",
      status: :received,
      priority: :normal,
      complaint: "Screen is cracked and the battery drains quickly.",
      received_at: Time.current,
      notes: "Customer wants a quote before repair."
    )
    wo.work_order_tasks.create!(description: "Diagnose device", assigned_user: tech, status: :pending, estimated_minutes: 30)
    wo.work_order_tasks.create!(description: "Replace screen", status: :pending, estimated_minutes: 60)

    screen = business.product_variants.find_by(sku: "IP15P-128")
    if screen
      wo.work_order_parts.create!(product_variant: screen, quantity: 1, unit_price_cents: screen.cost_price_cents, consumed: false)
    end
    wo.charges.create!(description: "Diagnostic", quantity: 1, unit_price_cents: 500_00, amount_cents: 500_00)

    wo.service_items.create!(tag_number: "WO-DEMO-01", name: "Phone charger", quantity: 1, condition: :good, received_at: Time.current, notes: "USB-C cable, 20W")
    wo.service_items.create!(tag_number: "WO-DEMO-02", name: "Clear case", quantity: 1, condition: :fair, received_at: Time.current, notes: "Minor scratches on back")
    puts "Created demo work order WO-DEMO"
  end
end

puts "Seed complete. Sign in as manager@cellshop.example / password123"
