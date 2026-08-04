# PRD-003 --- Cart, Sales Orders, Sales Returns & Payments

## 1. Objective

Implement the sales lifecycle for a cellphone retail shop.

## 2. Sales flow

``` text
Customer
  ↓
Cart
  ↓
SalesOrder
  ↓
Payment
  ↓
Inventory LineItem(sale)
```

The order expresses the commercial transaction; the inventory line item
records the actual stock movement.

## 3. Cart

### Fields

``` text
id
business_id
store_location_id
customer_id
status
created_by_user_id
created_at
updated_at
```

Statuses:

``` text
open
converted
abandoned
```

Cart lines should reference `ProductVariant`.

A cart is not an inventory transaction.

## 4. SalesOrder

### Fields

``` text
id
business_id
store_location_id
customer_id
number
status
subtotal
discount_total
tax_total
total
ordered_at
created_by_user_id
created_at
updated_at
```

Statuses:

``` text
draft
confirmed
partially_fulfilled
fulfilled
cancelled
completed
```

### Rules

-   Order number is unique within a business.
-   Customer is optional for anonymous/cash sales if the business allows
    it.
-   Store location is required.
-   Order totals are snapshots and must not change because a product's
    current price changes.
-   Confirming an order does not necessarily mean inventory has
    physically left stock.
-   Actual stock removal occurs when the sale is fulfilled/posted.

## 5. SalesOrderLine

### Fields

``` text
id
sales_order_id
product_variant_id
quantity
unit_price
discount
tax
total
```

Historical unit price must be stored on the line.

## 6. Sale posting

When the sale is posted:

``` text
SalesOrder
  ↓
For each fulfilled line
  ↓
Stock at order location
  ↓
LineItem(type: sale, quantity: -N)
```

For serialized products, the exact `InventoryItem`/IMEI must be
selected.

## 7. Sales Return

A sales return represents goods coming back from a customer.

### Fields

``` text
id
business_id
sales_order_id
customer_id
store_location_id
status
reason
created_at
```

A completed return creates:

``` text
LineItem(type: sales_return, quantity: +N)
```

Returned serialized devices must be inspected and assigned an
appropriate inventory status.

## 8. Payments

A payment represents money received for a sale.

### Fields

``` text
id
business_id
sales_order_id
cash_session_id
payment_method
amount
reference
status
paid_at
```

Payment methods:

``` text
cash
bank_transfer
card
gcash
maya
other
```

Payment processing should be independent from inventory posting.

## 9. Acceptance criteria

-   User can create a cart.
-   Cart can be converted to a sales order.
-   Sales order captures price snapshots.
-   Sale posting creates negative inventory line items.
-   Serialized phones require an exact inventory unit.
-   Sales returns create positive inventory movements.
-   Payments are recorded separately from inventory.
-   Repeated/retried posting cannot create duplicate inventory
    movements.
