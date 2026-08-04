# CellShop Commerce Platform --- PRD Set

## Purpose

This PRD set defines a commerce, inventory, POS, purchasing, transfer,
repair, and accounting platform initially optimized for a cellphone
sales and repair shop.

The architecture is intentionally domain-oriented and PostgreSQL-first
so the application can be implemented in Rails 8 and later ported to
Elixir/Phoenix/Ecto.

## Core business flow

``` text
Supplier
  ↓
PurchaseOrder
  ↓
Main Store Location
  ↓
TransferOrder
  ↓
Branch Store Location
  ↓
SalesOrder
  ↓
Customer
```

Repairs consume parts from the location where the repair is performed.

## Core principles

1.  `Business` is the tenant boundary.
2.  `StoreLocation` owns physical inventory.
3.  All purchasing is received into the main store location.
4.  Branch inventory is replenished through `TransferOrder`.
5.  `Stock` represents a product variant at a store location.
6.  `LineItem` represents an inventory movement against `Stock`.
7.  Orders express business intent; inventory line items express actual
    stock movement.
8.  Serialized cellphone inventory must support IMEI/serial tracking.
9.  `Account` means accounting/GL account only.
10. `Customer` means the commercial customer relationship.
11. `Supplier` means the commercial supplier relationship.
12. Avoid framework-dependent polymorphic associations where explicit
    relational models are practical.
13. Inventory and accounting changes must be transactional and
    auditable.
14. Completed historical transactions should be immutable; corrections
    should use reversal/adjustment transactions.

## PRD sequence

-   PRD-001 --- Business, Users, Customers, Suppliers & Store Locations
-   PRD-002 --- Product Catalog, Stock & Inventory
-   PRD-003 --- Sales, Cart, Returns & Payments
-   PRD-004 --- Purchasing & Transfer Orders
-   PRD-005 --- Repairs, POS & Cash Sessions
-   PRD-006 --- Accounting & Ledger

## Cross-cutting technical requirements

-   Rails 8
-   PostgreSQL
-   UUID or bigint IDs are acceptable, but use one convention
    consistently.
-   Foreign keys are required.
-   Unique constraints must be database-backed.
-   Monetary values must not use floating-point types.
-   Quantities must support fractional quantities if the business later
    needs them, but serialized units are integer quantities.
-   All timestamps are stored in UTC.
-   Business-local timezone is stored on `Business`.
-   Domain operations that change inventory must run inside database
    transactions.
-   Inventory movement creation must be idempotent when triggered from
    external/retryable workflows.
-   Authorization must enforce `business_id` tenant isolation.
-   Prefer explicit associations and tables over polymorphic database
    relationships.
-   State transitions must be explicit and validated.

## Future scope

Potential later modules:

-   supplier/customer credit terms
-   warranties
-   IMEI activation tracking
-   service contracts
-   barcode scanning
-   ecommerce channels
-   delivery/fulfillment
-   accounting reports
-   taxes
-   multi-currency
-   purchase receiving documents
-   inventory counts and adjustments
-   loyalty
-   promotions
