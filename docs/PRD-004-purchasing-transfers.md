# PRD-004 --- Purchasing, Receiving, Purchase Returns & Transfer Orders

## 1. Objective

Implement centralized purchasing and branch replenishment.

## 2. Core business rule

All supplier purchases enter the **Main Store Location**.

Branches are replenished through `TransferOrder`.

``` text
Supplier
  ↓
PurchaseOrder
  ↓
Main Store
  ↓
TransferOrder
  ↓
Branch
```

Branches do not receive supplier purchases directly in MVP.

## 3. PurchaseOrder

### Fields

``` text
id
business_id
supplier_id
destination_store_location_id
number
status
subtotal
tax_total
total
ordered_at
created_by_user_id
created_at
updated_at
```

The destination must be the business's main receiving location.

Statuses:

``` text
draft
submitted
approved
partially_received
received
cancelled
```

## 4. PurchaseOrderLine

``` text
id
purchase_order_id
product_variant_id
quantity
unit_cost
tax
total
```

## 5. Receiving

Receiving is the event that actually increases inventory.

``` text
PurchaseOrder
  ↓
Receive
  ↓
Stock at Main Store
  ↓
LineItem(type: purchase, quantity: +N)
```

The purchase order itself does not increase stock.

For serialized phones, receiving captures:

``` text
IMEI
serial number
condition
```

before the unit becomes available.

## 6. Purchase Return

A purchase return sends inventory back to the supplier.

``` text
Main Store
  ↓
PurchaseReturn
  ↓
Supplier
```

Completed return creates:

``` text
LineItem(type: purchase_return, quantity: -N)
```

For serialized products, the exact IMEI must be identified.

## 7. TransferOrder

A transfer is an internal inventory movement.

### Fields

``` text
id
business_id
origin_store_location_id
destination_store_location_id
number
status
requested_at
approved_at
shipped_at
received_at
completed_at
created_by_user_id
created_at
updated_at
```

### Rules

-   Origin and destination must be different.
-   Both locations must belong to the same business.
-   In MVP, normal branch replenishment originates from the main
    location.
-   Future versions may permit branch-to-branch transfers.
-   Transfer order does not immediately change inventory merely by being
    created.

Statuses:

``` text
draft
requested
approved
shipped
received
completed
cancelled
```

## 8. TransferOrderLine

``` text
id
transfer_order_id
product_variant_id
quantity
received_quantity
```

## 9. Transfer inventory behavior

At shipment:

``` text
Origin Stock
  LineItem(type: transfer, quantity: -N)
```

At receipt:

``` text
Destination Stock
  LineItem(type: transfer, quantity: +N)
```

This allows inventory to be represented as in-transit during the period
between shipment and receipt.

For serialized inventory, physical `InventoryItem` records move from
origin stock to destination stock at the appropriate operational point.

## 10. Acceptance criteria

-   Purchase orders can only target the main receiving location in MVP.
-   Receiving increases main-store stock.
-   Purchase order creation does not increase stock.
-   Purchase returns decrease main-store stock.
-   Transfer orders have explicit origin and destination locations.
-   Shipment decreases origin stock.
-   Receipt increases destination stock.
-   Transfer retry cannot duplicate movement.
-   Serialized phones retain their IMEI identity through transfers.
