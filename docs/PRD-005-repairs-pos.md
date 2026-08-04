# PRD-005 --- Repairs, Work Orders, POS & Cash Sessions

## 1. Objective

Support cellphone repair operations alongside retail sales.

## 2. WorkOrder

A work order represents a repair/service job.

### Fields

``` text
id
business_id
store_location_id
customer_id
number
status
problem_description
diagnosis
technician_user_id
received_at
completed_at
released_at
created_at
updated_at
```

Statuses:

``` text
received
diagnosing
awaiting_approval
approved
repairing
testing
ready
released
cancelled
```

## 3. Repair Device

A repair must identify the customer's physical device.

### Fields

``` text
id
work_order_id
brand
model
imei_1
imei_2
serial_number
condition
customer_notes
technician_notes
```

If the device is an inventory item sold by the business, the work order
may link to the existing serialized `InventoryItem`.

If the device was purchased elsewhere, it can still exist as a repair
device without becoming business inventory.

## 4. WorkOrderLine

Work lines may represent:

``` text
part
labor
service
```

Example:

``` text
iPhone 13 screen          ₱5,000
Adhesive                     ₱200
Labor                        ₱800
```

Parts reference product variants.

Labor/service lines do not consume inventory.

## 5. Consuming repair parts

When a part is actually used:

``` text
WorkOrder
  ↓
Part
  ↓
Stock at repair location
  ↓
LineItem(type: internal_use, quantity: -N)
```

Do not reduce stock merely because the part was estimated.

Only actual consumption changes inventory.

## 6. POS CashRegister

A `CashRegister` belongs to a store location.

### Fields

``` text
id
business_id
store_location_id
name
code
status
```

## 7. CashSession

Represents a cashier/register session.

### Fields

``` text
id
cash_register_id
user_id
status
opened_at
closed_at
opening_amount
expected_closing_amount
actual_closing_amount
difference
```

Statuses:

``` text
open
closing
closed
```

## 8. Cash movements

Cash sessions should eventually support:

``` text
sale
refund
cash_in
cash_out
opening
closing
adjustment
```

A payment made through cash is associated with the active cash session.

## 9. POS flow

``` text
Cashier
  ↓
Cart
  ↓
SalesOrder
  ↓
Payment
  ↓
CashSession
  ↓
Inventory posting
```

## 10. Acceptance criteria

-   Repair work orders can be created for customers.
-   Devices can be tracked by IMEI/serial.
-   Parts can be estimated without reducing stock.
-   Actual part consumption creates `internal_use` inventory movements.
-   Labor does not affect inventory.
-   Cashiers can open and close sessions.
-   Cash payments belong to a cash session.
-   Closing calculates expected vs actual cash.
