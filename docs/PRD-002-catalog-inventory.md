# PRD-002 --- Product Catalog, Product Variants, Stock & Inventory

## 1. Objective

Provide product catalog and location-based inventory management for a
cellphone sales and repair business.

The model must support both serialized products such as phones and
non-serialized products such as cases, chargers, cables, and screen
protectors.

## 2. Domain model

``` text
Category
  ↓
Product
  ↓
ProductVariant
  ↓
Stock
  ↓
LineItem
```

Serialized inventory:

``` text
ProductVariant
  ↓
Stock
  ↓
InventoryItem
```

## 3. Category

### Fields

``` text
id
business_id
parent_id
name
code
status
```

Categories may be hierarchical.

Example:

``` text
Phones
├── Apple
├── Samsung
└── Xiaomi

Accessories
├── Chargers
├── Cases
└── Cables
```

## 4. Product

Represents the product family.

Example:

``` text
iPhone 16
Samsung Galaxy S25
Anker USB-C Cable
```

### Fields

``` text
id
business_id
category_id
name
description
brand
status
created_at
updated_at
```

## 5. ProductVariant

Represents the sellable SKU.

Example:

``` text
iPhone 16
├── 128GB Black
├── 128GB White
├── 256GB Black
└── 256GB White
```

### Fields

``` text
id
business_id
product_id
sku
barcode
name
unit
cost_price
selling_price
track_serial
status
created_at
updated_at
```

### Rules

-   SKU is unique within a business.
-   A variant belongs to one product.
-   `track_serial = true` for phones and other serialized devices.
-   Serialized variants require one inventory unit per physical
    serialized device.

## 6. Stock

`Stock` is the inventory bucket for one product variant at one store
location.

### Fields

``` text
id
business_id
store_location_id
product_variant_id
quantity
reserved_quantity
created_at
updated_at
```

### Constraints

``` text
UNIQUE(store_location_id, product_variant_id)
```

### Rules

-   Stock belongs to one store location and one product variant.
-   Stock quantity cannot become negative unless negative inventory is
    explicitly enabled by business policy.
-   Reserved quantity cannot exceed quantity.
-   Stock is created automatically when a product variant is first used
    at a location.

## 7. LineItem

`LineItem` is an immutable inventory movement against a `Stock` record.

### Fields

``` text
id
business_id
stock_id
type
quantity
unit_cost
reference_type
reference_id
occurred_at
created_at
```

Types:

``` text
purchase
sale
sales_return
purchase_return
transfer
spoilage
internal_use
adjustment
```

Positive quantity adds inventory.

Negative quantity removes inventory.

Example:

``` text
Purchase       +10
Sale            -2
Sales return    +1
Spoilage        -1
Internal use    -1
Transfer        -3
```

### Rules

-   `LineItem` must belong to `Stock`.
-   `Stock` belongs to `ProductVariant`.
-   Quantity must not be zero.
-   Historical line items are immutable.
-   Inventory changes and line-item creation occur in one database
    transaction.
-   The reference must identify the operational event that caused the
    movement.
-   Do not use Rails polymorphic references if explicit reference tables
    are required for strict referential integrity. If polymorphic
    references are used, enforce application-level integrity and
    document it.

## 8. InventoryItem

Required for serialized products.

### Fields

``` text
id
business_id
stock_id
product_variant_id
serial_number
imei_1
imei_2
status
received_at
sold_at
created_at
updated_at
```

Statuses may include:

``` text
available
reserved
sold
repair
damaged
returned
```

### Rules

-   IMEI/serial must be unique within a business.
-   Serialized quantity must reconcile with physical inventory.
-   A serialized unit can belong to only one stock location at a time.
-   Transfers move the physical inventory item between locations.

## 9. Inventory calculation

`Stock.quantity` is the current operational balance.

`LineItem` is the immutable movement history.

The system should be able to reconcile:

``` text
opening quantity
+ positive movements
- negative movements
= current quantity
```

Do not calculate every stock read by summing the entire history.

## 10. Acceptance criteria

-   Product variants can be created with SKU/barcode.
-   Stock exists per location and variant.
-   Duplicate stock rows for the same location/variant are impossible.
-   Purchases increase stock.
-   Sales decrease stock.
-   Returns, spoilage, internal use, and transfers create appropriate
    movements.
-   Serialized phones can be tracked by IMEI.
-   Stock movement is auditable.
