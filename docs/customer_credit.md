# PRD — Customer Profile & Credit Management MVP

## 1. Objective

Provide a centralized customer profile where staff can view the customer's:

* Sales
* Repairs
* Invoices
* Payments
* Outstanding balances

The module must support:

* Cash and check payments
* Partial payments
* Credit SalesOrders
* Government/LGU customers paying by check
* Updating an existing credit SalesOrder as additional items are sold/delivered

**Sales entry itself is handled by the existing POS/Sales Transaction flow.**

---

# 2. Core Principle

The Customer Profile is **not another POS screen**.

Sales are entered through the existing POS flow:

```text
POS
 ↓
Scan / Search Product
 ↓
Add Items
 ↓
Select Customer
 ↓
Payment Method
 ├── Cash
 └── Credit
```

If the payment method is **Credit**, the POS creates a Credit SalesOrder.

```text
POS Sale
   ↓
Credit
   ↓
SalesOrder
   ↓
SalesInvoice
```

The Customer Profile is then used to find and manage the customer's history and receivables.

---

# 3. Customer Profile

Customer profile:

```text
Customer
ABC Trading

Phone
0917-123-4567

Email
abc@example.com

Outstanding
₱125,000

[ Sales ] [ Repairs ] [ Invoices ] [ Payments ]
```

The profile should provide quick access to the customer's transactions.

---

# 4. Customer Information

Minimum fields:

```text
Customer
--------
id
customer_number

customer_type
name

contact_person
phone
email

address
tin

notes

created_at
updated_at
```

Customer types:

```text
Individual
Organization
```

No separate customer models are required for MVP.

---

# 5. Customer Tabs

The profile contains four tabs:

```text
[ Sales ]
[ Repairs ]
[ Invoices ]
[ Payments ]
```

The tabs are views into existing domain records.

They do not duplicate those records.

---

# 6. Sales Tab

Display the customer's SalesOrders.

Example:

```text
SALES

Order        Type       Total       Status
SO-10025     Credit     ₱100,000    In Progress
SO-10030     Cash        ₱25,000    Completed
SO-10041     Credit      ₱50,000    Completed
```

Selecting an order opens the SalesOrder.

The Sales tab should provide:

```text
[ New Sale ]
```

which opens the **existing POS Sales Transaction flow**.

It must not implement a separate sales-entry form.

---

# 7. New Sale

When the user selects:

```text
[ New Sale ]
```

the system opens the existing POS flow.

The customer may already be selected.

```text
Customer:
ABC Trading
```

The clerk then:

```text
Scan / Search Product
        ↓
Add Items
        ↓
Review Cart
        ↓
Select Payment
```

Payment options:

```text
Cash
Credit
```

---

# 8. Credit Sale From POS

When the clerk selects:

```text
Credit
```

the POS creates a Credit SalesOrder.

Example:

```text
SO-2026-001

Customer:
City Government of Angeles

Payment:
Credit

Items:
100 × Desktop Computer

Total:
₱4,000,000
```

The SalesOrder is associated with the Customer.

The corresponding SalesInvoice is created according to the finalized Sales Transaction rules.

The clerk does not need to manually create the SalesOrder or Invoice.

---

# 9. Government / Contract Sales

A SalesOrder may optionally reference a Contract.

```text
Contract
   ↓
SalesOrder
```

For a government contract sale:

```text
Customer
City Government of Angeles

Contract
CONTRACT-2026-001

SalesOrder
SO-2026-001
```

The Contract is only a reference.

Contract management remains within the Contracts module.

---

# 10. Updating an Existing Credit SalesOrder

Government and institutional customers may receive goods over multiple deliveries.

The same Credit SalesOrder remains open.

Example:

```text
SO-2026-001

Desktop Computers
Ordered:    100
Delivered:   30
Remaining:   70
```

The Sales Clerk can open the existing SalesOrder and add/update the items.

Later:

```text
Desktop Computers
Ordered:    100
Delivered:   70
Remaining:   30
```

Eventually:

```text
Desktop Computers
Ordered:    100
Delivered:  100
Remaining:    0
```

No new SalesOrder is created for each delivery.

No Fulfillment model is required for MVP.

---

# 11. Updating Existing Orders vs New Sales

The system should clearly distinguish two actions.

### New Sale

```text
Customer
 ↓
New Sale
 ↓
POS
 ↓
Create SalesOrder
```

### Existing Credit Order

```text
Customer
 ↓
Sales
 ↓
Existing Credit SalesOrder
 ↓
Update/Add Items
 ↓
Save
```

The clerk should never accidentally create a second SalesOrder when they are continuing an existing government order.

---

# 12. SalesOrder Quantity Validation

For an existing Credit SalesOrder:

```text
Ordered:
100

Delivered:
70

Remaining:
30
```

The system must prevent the clerk from exceeding the original order quantity.

Example:

```text
Attempted additional quantity:
40
```

The system should display:

```text
Only 30 units remain on this SalesOrder.
```

---

# 13. SalesOrder and Invoice

A Credit SalesOrder is associated with its SalesInvoice.

```text
SalesOrder
    ↓
SalesInvoice
```

For the MVP:

> **One Credit SalesOrder has one SalesInvoice.**

The same SalesOrder and Invoice remain associated while the order is being updated.

There is no partial-invoice model.

There is no multiple-invoice workflow for this MVP.

---

# 14. Invoice Tab

The Invoices tab displays the customer's invoices.

Example:

```text
INVOICES

Invoice       Source       Total       Paid       Balance
INV-10025     SO-10025     ₱100,000    ₱30,000    ₱70,000
INV-10031     WO-10031      ₱20,000     ₱5,000    ₱15,000
```

The invoice identifies its source:

```text
SalesInvoice
→ SalesOrder

RepairInvoice
→ WorkOrder
```

---

# 15. Invoice Responsibility

The Invoice represents the customer's bill.

It is responsible for:

* Invoice number
* Customer
* Source transaction
* Invoice date
* Total
* Payment status
* Outstanding balance

It does not manage:

* Inventory
* Sales workflow
* Repair workflow
* Cash handling
* Check clearing
* Accounting entries

---

# 16. Recording a Payment

Payment entry starts from an Invoice.

```text
Customer
 ↓
Invoices
 ↓
Select Invoice
 ↓
[ Record Payment ]
 ↓
Cash / Check
 ↓
Preview
 ↓
Confirm
```

The clerk does not enter a generic payment and then decide which transaction it applies to.

Every payment belongs to exactly one Invoice.

---

# 17. Partial Payments

An Invoice may receive multiple payments.

Example:

```text
Invoice:
₱100,000
```

Payment 1:

```text
Cash
₱20,000
```

Payment 2:

```text
Check #12345
₱30,000
```

Invoice:

```text
Total:
₱100,000

Paid:
₱50,000

Balance:
₱50,000

Status:
Partially Paid
```

A later payment can settle the remaining balance.

---

# 18. Payment Methods

MVP supports:

```text
Cash
Check
```

No external payment gateway integration.

---

# 19. Cash Payment

Example:

```text
RECORD PAYMENT

Invoice:
INV-10025

Outstanding:
₱70,000

Amount:
₱30,000

Payment Method:
Cash

[ Preview ]
```

After preview:

```text
PAYMENT PREVIEW

Amount:
₱30,000

Method:
Cash

Invoice Balance After Payment:
₱40,000

[ Confirm ]
[ Cancel ]
```

---

# 20. Check Payment

Example:

```text
RECORD PAYMENT

Invoice:
INV-10025

Outstanding:
₱70,000

Amount:
₱70,000

Payment Method:
Check

Check Number:
00012345

Bank:
LandBank

Check Date:
August 3, 2026

[ Preview ]
```

This supports LGUs and businesses that commonly pay through checks.

---

# 21. Check Status

A check payment may have:

```text
Received
Deposited
Cleared
Bounced
Cancelled
```

When initially recorded:

```text
Received
```

The business can later update the status.

---

# 22. Payment Validation

The system must prevent:

```text
Payment Amount > Invoice Balance
```

Example:

```text
Invoice Balance:
₱30,000

Payment:
₱35,000
```

The system rejects the payment.

---

# 23. Payment Model

Use an explicit model:

```text
CustomerPayment
---------------
id

customer_id
invoice_id

amount
payment_method

payment_date
reference
notes

created_by_id
created_at
updated_at
```

Payment methods:

```text
cash
check
```

Check-specific fields should be explicit rather than stored in JSONB.

For example:

```text
check_number
check_bank
check_date
check_status
```

---

# 24. Payments Tab

Display all payments made by the customer.

```text
PAYMENTS

Date       Invoice     Method    Reference    Amount
Aug 01     INV-10025   Cash      —            ₱20,000
Aug 03     INV-10025   Check     #12345       ₱30,000
Aug 05     INV-10031   Cash      —             ₱5,000
```

Selecting a payment displays its details.

---

# 25. Customer Financial Summary

At the top of the profile:

```text
TOTAL SALES
₱500,000

TOTAL REPAIRS
₱80,000

TOTAL PAID
₱420,000

OUTSTANDING
₱160,000
```

These values are calculated from transaction records.

They are not manually maintained fields on Customer.

---

# 26. Invoice Status

Invoice payment status:

```text
Unpaid
Partially Paid
Paid
```

Example:

```text
Total:
₱100,000

Paid:
₱30,000

Status:
Partially Paid
```

After the final payment:

```text
Total:
₱100,000

Paid:
₱100,000

Status:
Paid
```

---

# 27. SalesOrder Status vs Invoice Status

These are separate concepts.

Example:

```text
SalesOrder:
In Progress

Invoice:
Partially Paid
```

Or:

```text
SalesOrder:
Completed

Invoice:
Unpaid
```

The payment status must never determine the operational SalesOrder status.

---

# 28. Sales Clerk Workflow

### New Sale

```text
POS
 ↓
Select Customer
 ↓
Scan / Search Items
 ↓
Review
 ↓
Credit
 ↓
SalesOrder + SalesInvoice
```

### Continue Existing Credit Order

```text
Customer
 ↓
Sales
 ↓
Open Credit SalesOrder
 ↓
Add / Update Items
 ↓
Save
```

### Receive Payment

```text
Customer
 ↓
Invoices
 ↓
Open Invoice
 ↓
Record Payment
 ↓
Cash / Check
 ↓
Preview
 ↓
Confirm
```

---

# 29. Manager Workflow

Manager can perform the same workflows as the Sales Clerk and can additionally:

* Create/edit customers
* Manage customer information
* Create/manage Contracts
* Manage SalesOrders according to existing Sales rules
* View invoices
* Record payments
* Manage check status
* View customer financial history

---

# 30. Hotwire / Stimulus UX

Use Hotwire and Stimulus to make the workflows fast and difficult to misuse.

### Customer Profile

Tabs should switch without a full-page reload.

### POS

Reuse the existing POS implementation.

Do not duplicate POS logic inside Customer Profile.

### Payment

Selecting Cash displays cash payment fields.

Selecting Check displays:

```text
Check Number
Bank
Check Date
```

### Existing SalesOrder

Show:

```text
Ordered
Delivered
Remaining
```

Update remaining quantities immediately.

Prevent invalid quantities before submission.

---

# 31. Accounting / Treasury Flow

Payment confirmation follows the existing Sirib transaction pattern.

### Cash

```text
Invoice
 ↓
Record Payment
 ↓
Preview
 ↓
Confirm
 ↓
Cash Receipt Voucher
 ↓
Accounting Entry
```

A Voucher is created because a CashAccount is involved.

### Check

```text
Invoice
 ↓
Record Check Payment
 ↓
Preview
 ↓
Confirm
 ↓
Treasury / Accounting
```

A Voucher is created only when the transaction involves a CashAccount, following the existing Sirib rule.

---

# 32. Domain Responsibilities

### Customers

Responsible for:

```text
Customer profile
Customer information
```

### Orders

Responsible for:

```text
SalesOrders
SalesOrderLineItems
Credit SalesOrder updates
```

### Repairs

Responsible for:

```text
WorkOrders
Repair charges
```

### Invoices

Responsible for:

```text
SalesInvoices
RepairInvoices
Invoice balances
Invoice payment status
```

### Treasury

Responsible for:

```text
CustomerPayments
Cash
Checks
Check status
```

### Accounting

Responsible for:

```text
Accounting Entries
Accounts
Amount Lines
```

---

# 33. Final Relationships

```text
Customer
   │
   ├── SalesOrder
   │       │
   │       └── SalesInvoice
   │               │
   │               └── CustomerPayments
   │
   └── WorkOrder
           │
           └── RepairInvoice
                   │
                   └── CustomerPayments
```

Government sale:

```text
Contract
   ↓
Credit SalesOrder
   ↓
Same SalesOrder updated over time
   ↓
Same SalesInvoice
   ↓
Multiple Payments
```

---

# 34. MVP Rules

1. Sales entry uses the existing POS flow.
2. The Customer Profile does not duplicate POS functionality.
3. Selecting **Credit** in POS creates a Credit SalesOrder.
4. A Credit SalesOrder has a SalesInvoice.
5. A government/contract SalesOrder can remain open while additional items are delivered.
6. The same SalesOrder is updated instead of creating another order.
7. The same SalesInvoice remains associated with the SalesOrder.
8. One Invoice can receive multiple Payments.
9. One Payment belongs to exactly one Invoice.
10. Payments support Cash and Check.
11. Check payments have explicit check information.
12. Partial payments are supported.
13. Payment cannot exceed the outstanding invoice balance.
14. SalesOrder status and Invoice payment status are separate.
15. No partial-invoice model is required.
16. No Fulfillment model is required for MVP.
17. No payment allocation model is required.
18. No external payment gateway is required.
19. Contract is an optional reference on a SalesOrder.
20. Customer Profile is primarily for **finding, reviewing, and managing customer history and receivables**.
