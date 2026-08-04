# PRD — Stock Quantity Computation

## 1. Objective

Provide a reliable and simple mechanism for maintaining the current stock quantity of every Product at every Store Location.

The system must:

* Maintain a `quantity` column on `stocks`.
* Never allow stock to become negative.
* Increase or decrease stock only through confirmed inventory transactions.
* Keep an explicit history through domain-specific line items.
* Make current quantity fast to retrieve for sales, purchasing, repairs, and reporting.
* Avoid polymorphic inventory associations.
* Avoid JSONB inventory metadata.

---

# 2. Stock Model

```text
Stock
-----
id

product_id
store_location_id

quantity

created_at
updated_at
```

`quantity` represents the **current available physical stock** for that Product at that Store Location.

Example:

```text
Product:
Kingston 8GB RAM

Store:
Main Branch

Quantity:
42
```

---

# 3. Stock Uniqueness

There can only be one Stock record for a Product at a Store Location.

```text
UNIQUE(product_id, store_location_id)
```

Example:

```text
Kingston 8GB RAM
 ├── Main Branch → Stock: 42
 ├── Baguio Branch → Stock: 15
 └── Angeles Branch → Stock: 8
```

---

# 4. Stock Quantity Is Maintained, Not Manually Edited

`stocks.quantity` is a stored value for operational and reporting performance.

It must **not** be directly edited by users.

Instead:

```text
Inventory Transaction
        ↓
Confirmed
        ↓
Update Stock.quantity
```

Example:

```text
Current Stock:
20

Purchase:
+10

Stock.quantity:
30
```

---

# 5. Inventory Line Items

Each inventory-affecting domain has an explicit line-item model.

```text
SalesLineItem
SalesReturnLineItem

PurchaseLineItem
PurchaseReturnLineItem

TransferOrderLineItem
SpoilageOrderLineItem
InternalUseOrderLineItem

StockOpeningLineItem
StockAdjustmentLineItem
```

No polymorphic `InventoryTransaction` association is required.

---

# 6. Stock Effects

| Transaction               | Effect |
| ------------------------- | -----: |
| Opening Stock             |      + |
| Purchase Receipt          |      + |
| Sales Return              |      + |
| Transfer In               |      + |
| Stock Adjustment Increase |      + |
| Sale                      |      − |
| Purchase Return           |      − |
| Transfer Out              |      − |
| Spoilage                  |      − |
| Internal Use              |      − |
| Stock Adjustment Decrease |      − |

---

# 7. Sales

Sales decrease stock.

```text
SalesLineItem
quantity = 3
```

Result:

```text
Stock.quantity -= 3
```

Example:

```text
Before:
10

Sale:
3

After:
7
```

---

# 8. Sales Returns

Sales returns increase stock.

```text
SalesReturnLineItem
quantity = 1
```

Result:

```text
Stock.quantity += 1
```

---

# 9. Purchases

Only **received inventory** increases stock.

Creating a PurchaseOrder does not affect stock.

```text
PurchaseOrder
     ↓
Receive
     ↓
PurchaseLineItem
     ↓
Stock.quantity += quantity
```

Example:

```text
Ordered:
100

Received:
40

Stock increase:
40
```

The remaining 60 does not enter stock.

---

# 10. Purchase Returns

Purchase returns decrease stock.

```text
PurchaseReturnLineItem
quantity = 5

Stock.quantity -= 5
```

---

# 11. Transfers

A transfer affects two Stock records.

Example:

```text
Main Branch:
100

Transfer:
30

Baguio Branch:
20
```

After confirmation:

```text
Main Branch:
70

Baguio Branch:
50
```

Conceptually:

```text
TransferOrderLineItem
        │
        ├── Source Stock       -30
        │
        └── Destination Stock  +30
```

The entire transfer must succeed or fail as one database transaction.

---

# 12. Spoilage

Spoilage decreases stock.

```text
SpoilageOrderLineItem
quantity = 2

Stock.quantity -= 2
```

---

# 13. Internal Use

Internal use decreases stock.

```text
InternalUseOrderLineItem
quantity = 1

Stock.quantity -= 1
```

This is also used by the Repair domain.

Example:

```text
WorkOrder
    ↓
InternalUseOrder
    ↓
InternalUseOrderLineItem
    ↓
Stock
```

A technician consuming a spare part therefore reduces inventory through the normal Internal Use flow.

---

# 14. Opening Stock

Initial inventory is established through an explicit opening transaction.

```text
StockOpening
StockOpeningLineItem
```

Example:

```text
Product:
Dell Laptop

Opening Quantity:
25
```

Result:

```text
Stock.quantity += 25
```

Opening stock should not be entered by directly editing `stocks.quantity`.

---

# 15. Stock Adjustments

Physical inventory counts may reveal a discrepancy.

Example:

```text
System Quantity:
50

Physical Count:
48
```

The system creates:

```text
StockAdjustmentLineItem
quantity = -2
```

Result:

```text
Stock.quantity = 48
```

For an increase:

```text
System:
50

Physical:
53

Adjustment:
+3
```

---

# 16. Stock Adjustment Rules

Stock adjustments require:

```text
product
store_location
quantity
reason
created_by
```

A user cannot directly edit:

```text
stocks.quantity
```

All changes must have an identifiable transaction.

---

# 17. Negative Stock Is Not Allowed

The system must **never allow `stocks.quantity` to become negative**.

Example:

```text
Current Stock:
5

Sale:
7
```

The transaction must be rejected.

```text
Insufficient stock.

Available: 5
Requested: 7
```

No partial automatic sale should occur.

---

# 18. Atomic Stock Validation

Stock validation and stock modification must happen atomically.

Example:

```text
Current Stock:
5
```

Two cashiers attempt:

```text
Cashier A → sell 4
Cashier B → sell 3
```

The system must not allow both transactions to succeed.

The database transaction must:

1. Lock/check the Stock record.
2. Verify sufficient quantity.
3. Apply the quantity change.
4. Commit the inventory transaction.

If sufficient stock does not exist, the transaction fails.

---

# 19. Confirmed Transactions Only

Only transactions that reach their inventory-affecting status modify `stocks.quantity`.

For example:

```text
SalesOrder

Draft
  ↓
Confirmed
  ↓
Released
  ↓
STOCK DECREASE
```

A cancelled or draft transaction has no stock effect.

Similarly:

```text
Purchase

Draft
  ↓
Confirmed
  ↓
Received
  ↓
STOCK INCREASE
```

---

# 20. Transaction Corrections

Once a transaction has changed stock, its historical quantity should not simply be edited.

Instead use the appropriate reversal mechanism.

Example:

```text
Sale
-5
```

If it must be reversed:

```text
Sales Return
+5
```

Or where appropriate:

```text
Stock Adjustment
```

This preserves an auditable inventory history.

---

# 21. Stock History

Although `stocks.quantity` is stored, users should be able to understand how the number was produced.

Example:

```text
PRODUCT: Kingston 8GB RAM
STORE: Main Branch

Date        Transaction       Qty     Balance
------------------------------------------------
Aug 01      Opening Stock     +20        20
Aug 01      Purchase          +10        30
Aug 02      Sale               -5        25
Aug 02      Internal Use       -1        24
Aug 03      Sales Return       +1        25
Aug 03      Spoilage           -2        23
```

The `quantity` column is the current balance.

The line items provide the history.

---

# 22. Reporting

The stored `stocks.quantity` should be used for normal reporting.

Examples:

### Current Stock Report

```text
Product             Location        Quantity
------------------------------------------------
Kingston 8GB RAM    Main Branch       42
Dell Laptop         Main Branch       15
Motul Oil           Main Branch       28
```

### Low Stock Report

```text
Product             Quantity
-----------------------------
Kingston 8GB RAM        2
Dell Laptop             1
```

### Inventory Valuation

The system can later combine:

```text
Stock.quantity
×
Cost
```

to produce inventory value.

Inventory costing methodology should be defined separately.

---

# 23. Product-Level Availability

When a transaction needs stock, the system checks:

```text
Stock
where:
product_id = requested product
store_location_id = current store location
```

Example:

```text
Main Branch
Dell Laptop
Quantity: 4
```

A sale of 3 is allowed.

A sale of 5 is rejected.

---

# 24. Store Location Isolation

Stock belongs to a Store Location.

A transaction at one location must never accidentally consume stock from another.

Example:

```text
Main Branch:
10

Baguio Branch:
5
```

A Main Branch sale of 8 results in:

```text
Main Branch:
2

Baguio Branch:
5
```

Baguio inventory is untouched.

---

# 25. Stock Computation Model

The conceptual calculation remains:

```text
Current Quantity

= Opening Stock
+ Purchases
+ Sales Returns
+ Transfer In
+ Positive Adjustments

- Sales
- Purchase Returns
- Transfer Out
- Spoilage
- Internal Use
- Negative Adjustments
```

However, this calculation is **not performed from scratch every time the stock is displayed**.

Instead, each confirmed inventory transaction updates:

```text
stocks.quantity
```

---

# 26. Quantity as a Cached/Materialized Operational Value

`stocks.quantity` is the authoritative **current operational balance**.

Historical line items are the authoritative **transaction history**.

This gives the system:

```text
Fast current stock:
stocks.quantity

Auditable history:
inventory-affecting line items
```

The application should not calculate current stock by summing thousands of historical line items on every page load.

---

# 27. Reconciliation

Because `stocks.quantity` is maintained rather than calculated dynamically, the system should provide a way to detect inconsistencies.

A reconciliation process can calculate:

```text
Expected Quantity
=
Opening
+ Adds
- Removes
```

and compare it against:

```text
stocks.quantity
```

For MVP, this can be an internal/admin operation rather than a complex user-facing feature.

Example:

```text
Stored Quantity:
42

Calculated Quantity:
42

Status:
OK
```

If:

```text
Stored Quantity:
42

Calculated Quantity:
40

Status:
MISMATCH
```

This helps detect programming or data-integrity errors.

---

# 28. Database Integrity

The database should enforce:

```text
quantity >= 0
```

This provides a second layer of protection in addition to application-level validation.

The system should therefore have:

```text
Application validation
        +
Database constraint
```

against negative stock.

---

# 29. Quantity Type

For the initial MVP, use an integer quantity for countable products.

Examples:

```text
Laptop:
5

Motorcycle:
3

RAM:
20
```

If the business later requires products sold by:

* kilogram
* liter
* meter
* box
* fractional quantity

the quantity model can be extended separately.

Do not add complex unit conversion to the MVP unless a target customer actually requires it.

---

# 30. Domain Responsibility

The Stock domain is responsible for:

* Current quantity
* Availability
* Increasing stock
* Decreasing stock
* Preventing negative stock
* Maintaining stock history
* Store-level inventory

The Sales domain is responsible for:

* SalesOrders
* SalesLineItems
* Customer sales

The Purchase domain is responsible for:

* Purchases
* PurchaseLineItems
* Supplier purchases

The Repair domain is responsible for:

* WorkOrders
* Repair charges
* Parts consumed

The Inventory/Stock domain connects these effects without taking ownership of the business workflows.

---

# 31. No Polymorphic Inventory Model

Do not introduce:

```text
inventory_transaction
inventoryable_type
inventoryable_id
```

or:

```text
stockable_type
stockable_id
```

Instead, keep explicit domain relationships:

```text
Stock
 ├── SalesLineItems
 ├── SalesReturnLineItems
 ├── PurchaseLineItems
 ├── PurchaseReturnLineItems
 ├── TransferOrderLineItems
 ├── SpoilageOrderLineItems
 ├── InternalUseOrderLineItems
 ├── StockOpeningLineItems
 └── StockAdjustmentLineItems
```

This keeps the model explicit and makes the domain easier to port to Elixir later.

---

# 32. Final MVP Rules

1. Every Product/Store Location combination has one Stock record.
2. `stocks.quantity` stores the current stock balance.
3. Users cannot manually edit `stocks.quantity`.
4. Every inventory change comes from a confirmed inventory transaction.
5. Sales decrease stock.
6. Sales returns increase stock.
7. Purchases increase stock only when received.
8. Purchase returns decrease stock.
9. Transfers decrease source stock and increase destination stock.
10. Spoilage decreases stock.
11. Internal Use decreases stock.
12. Opening Stock increases stock.
13. Stock Adjustments can increase or decrease stock.
14. Stock can never become negative.
15. Application-level validation prevents insufficient stock.
16. Database constraints prevent negative quantity.
17. Stock validation and modification are atomic.
18. Cancelled/draft transactions do not affect stock.
19. Historical inventory transactions are not silently edited after posting.
20. Stock history is retained through explicit line-item records.
21. `stocks.quantity` is used for fast operational queries and reports.
22. Historical line items provide the audit trail.
23. Stock is always scoped to Store Location.
24. No polymorphic inventory associations are required.
25. No JSONB metadata is required.
26. A reconciliation mechanism can verify stored quantity against transaction history.

---

# 33. Final Architecture

```text
                    PRODUCT
                       │
                       │
                STORE LOCATION
                       │
                       ▼
                     STOCK
                       │
                 quantity = 42
                       │
       ┌───────────────┼────────────────┐
       │               │                │
       ▼               ▼                ▼
    SALES          PURCHASES        REPAIRS
       │               │                │
       ▼               ▼                ▼
SalesLineItems   PurchaseLineItems  InternalUse
       │               │                │
       └───────────────┼────────────────┘
                       ▼
                 STOCK QUANTITY
```

The key design decision is:

> **`stocks.quantity` is a stored current balance for performance and reporting, while explicit inventory line items provide the complete history of how that balance changed.**

That gives you the simplicity you want without sacrificing auditability or performance.
