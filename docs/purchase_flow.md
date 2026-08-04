# PRD — Purchasing Workflow

**Product:** Sirib
**Module:** Purchasing
**Status:** MVP
**Stack:** Rails 8 + Hotwire + Stimulus

---

## 1. Goal

Provide a simple purchasing workflow for SMEs where:

* **Purchase Clerk** records the purchase details.
* **Manager** reviews and decides whether the purchase is **Cash** or **Credit**.
* **Manager** sets the selling price for each store location.
* **Manager** can perform every purchasing action when they are the current user.

The workflow should be simple enough for a purchase clerk to use without understanding accounting.

---

# 2. Roles

## Purchase Clerk

Can:

* Create purchase
* Select supplier
* Enter purchase reference
* Add products
* Enter quantities
* Enter supplier cost
* Review purchase details
* Submit purchase for manager decision

Cannot:

* Decide Cash vs Credit
* Create cash disbursement
* Confirm supplier payment
* Set selling prices
* Change another user's purchase

---

## Manager

Can do everything a Purchase Clerk can do, plus:

* Approve purchase
* Decide Cash or Credit
* Set selling prices
* Confirm cash payment
* Review accounting impact
* Cancel/reject purchase

If the current user is a Manager, they do not need a separate approval step.

```text
Manager
   ↓
Can create purchase
   ↓
Can decide payment
   ↓
Can set prices
   ↓
Can confirm
```

---

# 3. Purchase Flow

```text
Purchase Clerk
      ↓
Enter Purchase
      ↓
Submit
      ↓
Manager Review
      ↓
Cash OR Credit
      ↓
Confirm Purchase
      ↓
Receive into Main Store
      ↓
Set Store Selling Prices
```

If the manager chooses Cash:

```text
Purchase
   ↓
Cash Payment
   ↓
Cash Disbursement Voucher
   ↓
Accounting Entry
```

If Credit:

```text
Purchase
   ↓
Accounts Payable
   ↓
No Voucher
```

---

# 4. Purchase Location

All purchases are received into:

> **Main Store Location**

The Purchase Clerk does not select the receiving location.

Example:

```text
Business
 ├── Main Store
 ├── Branch 1
 └── Branch 2
```

Purchase:

```text
Supplier
   ↓
Main Store
```

Inventory can later be moved using `TransferOrder`.

---

# 5. Creating a Purchase

Purchase Clerk selects:

```text
New Purchase
```

The system creates a draft.

Required information:

```text
Supplier
Purchase Date
Supplier Reference
Items
Quantity
Unit Cost
```

Example:

```text
Supplier:
ABC Electronics

Supplier Invoice:
INV-2026-00125

Items:

Kingston SSD
Qty: 10
Cost: ₱2,200

Logitech Mouse
Qty: 20
Cost: ₱500
```

---

# 6. Purchase Status

Keep the state machine simple:

```text
draft
pending_approval
confirmed
cancelled
```

Flow:

```text
Draft
  ↓
Pending Approval
  ↓
Confirmed
```

Or:

```text
Pending Approval
  ↓
Cancelled
```

If the Manager creates the purchase:

```text
Draft
  ↓
Confirmed
```

---

# 7. Purchase Clerk Submit

When finished:

```text
[ SUBMIT FOR APPROVAL ]
```

The purchase becomes:

```text
pending_approval
```

The clerk cannot change the financial decision.

The Manager receives a list of purchases requiring review.

---

# 8. Manager Review

Manager opens:

```text
Purchase #PO-10025
```

They see:

```text
Supplier:
ABC Electronics

Invoice:
INV-2026-00125

Items:
--------------------------------
Kingston SSD
10 × ₱2,200       ₱22,000

Logitech Mouse
20 × ₱500         ₱10,000
--------------------------------

TOTAL              ₱32,000

Receiving:
Main Store
```

Then:

```text
Payment Method

[ CASH ]   [ CREDIT ]
```

---

# 9. Manager Chooses Credit

If Manager selects:

```text
CREDIT
```

the purchase creates:

```text
Inventory
    ↑
₱32,000

Accounts Payable
    ↑
₱32,000
```

No cash voucher is created.

The purchase becomes:

```text
confirmed
```

---

# 10. Manager Chooses Cash

If Manager selects:

```text
CASH
```

the system requires a Cash Account.

Example:

```text
Cash Account:
Main Store Cash

Amount:
₱32,000
```

The manager reviews:

```text
Purchase:
₱32,000

Payment:
Cash

Cash Account:
Main Store Cash
```

Then:

```text
[ CONFIRM PURCHASE & PAYMENT ]
```

The system creates the required Cash Disbursement Voucher and accounting entry.

---

# 11. Accounting

## Credit Purchase

```text
Debit:
Inventory

Credit:
Accounts Payable
```

Example:

```text
Dr Inventory              ₱32,000
Cr Accounts Payable       ₱32,000
```

---

## Cash Purchase

Operationally the manager chooses Cash.

The resulting accounting is:

```text
Dr Inventory              ₱32,000
Cr Cash                   ₱32,000
```

The cash portion must be represented through:

```text
Cash Disbursement Voucher
```

followed by the accounting entry.

---

# 12. Inventory Receiving

Once the purchase is confirmed:

```text
Purchase
   ↓
Main Store
   ↓
Stock increases
```

Example:

```text
Kingston SSD
Existing Stock: 20

Purchase: +10

New Stock: 30
```

The inventory movement is recorded through the purchase line item.

---

# 13. Selling Price

The purchase cost is **not automatically the selling price**.

The Manager decides the selling price.

Example:

```text
Purchase Cost:
₱2,200

Main Store Selling Price:
₱2,800
```

The manager may set:

```text
Store Location
Product Variant
Selling Price
```

---

# 14. Store-Specific Pricing

Selling prices belong to the store location.

Example:

```text
Kingston SSD

Main Store:
₱2,800

Branch 1:
₱2,900

Branch 2:
₱3,000
```

This allows the business to operate different pricing per branch.

The price should be associated with:

```text
StoreLocation
ProductVariant
Price
```

rather than putting a price directly on the product.

---

# 15. Manager Price Setting

After confirming a purchase, the Manager may see:

```text
NEW INVENTORY

Kingston SSD
Cost: ₱2,200

Store Prices

Main Store
[ ₱2,800 ]

Branch 1
[ ₱2,900 ]

Branch 2
[ ₱3,000 ]

[ SAVE PRICES ]
```

For MVP, only Managers can change these prices.

---

# 16. Manager as Current User

Do not create a separate manager workflow.

The authorization should simply determine what the current user is allowed to do.

If:

```text
Current.user.role == manager
```

they can:

```text
Create Purchase
        ↓
Review
        ↓
Choose Cash/Credit
        ↓
Confirm
        ↓
Set Prices
```

There should be no artificial:

```text
Submit
   ↓
Log out
   ↓
Manager logs in
```

requirement.

---

# 17. Purchase Clerk Workflow

The Purchase Clerk sees:

```text
PURCHASE

Supplier
[ ABC Electronics ]

Invoice #
[ INV-2026-00125 ]

Items
[ Scan / Search Product ]

--------------------------------
SSD       10 × ₱2,200    ₱22,000
Mouse     20 × ₱500      ₱10,000
--------------------------------

TOTAL                  ₱32,000

[ SUBMIT FOR APPROVAL ]
```

That's it.

The clerk does not see unnecessary accounting controls.

---

# 18. Manager Workflow

Manager sees:

```text
PURCHASE REVIEW

Supplier:
ABC Electronics

Total:
₱32,000

Receiving:
Main Store

Payment:

○ Cash
○ Credit

[ CONFIRM PURCHASE ]
```

If Cash:

```text
Cash Account
[ Main Store Cash ]

[ CONFIRM PURCHASE ]
```

If Credit:

```text
Customer/Supplier:
ABC Electronics

[ CONFIRM PURCHASE ]
```

---

# 19. Hotwire + Stimulus

The workflow should use Hotwire to keep the interaction fast.

### Turbo Frames

Use frames for:

```text
purchase_items
purchase_totals
purchase_review
payment_method
store_prices
```

### Stimulus

Use Stimulus for:

```text
barcode scanning
quantity changes
price calculations
payment method switching
button states
keyboard navigation
```

Business rules remain server-side.

---

# 20. Purchase Confirmation

Confirmation must be transactional.

Conceptually:

```ruby
transaction do
  validate_purchase

  receive_inventory

  if credit?
    create_accounts_payable
  else
    create_cash_disbursement_voucher
    create_accounting_entry
  end

  confirm_purchase
end
```

The operation must either complete entirely or roll back.

---

# 21. Important Rule

The system must never:

* Receive inventory without a confirmed purchase.
* Create a cash transaction without a voucher.
* Create a payable for a cash purchase.
* Deduct cash for a credit purchase.
* Change selling prices without Manager authorization.
* Receive a purchase into a non-main location.
* Create duplicate purchases from double submission.

---

# 22. Purchase Data

Minimum Purchase Order:

```text
PurchaseOrder
----------------
id
business_id
supplier_id
created_by_id
status
purchase_date
supplier_reference
total
```

Purchase Line Item:

```text
LineItem
----------------
id
purchase_order_id
stock_id
quantity
unit_cost
amount
```

The existing `LineItem` domain can represent:

```text
purchase
sales
sales_return
purchase_return
transfer
spoilage
internal_use
```

For purchasing:

```text
line_item.type = purchase
```

---

# 23. Acceptance Criteria

### Purchase Clerk

* [ ] Can create purchase.
* [ ] Can select supplier.
* [ ] Can enter supplier reference.
* [ ] Can scan/search products.
* [ ] Can enter quantity.
* [ ] Can enter purchase cost.
* [ ] Can review totals.
* [ ] Can submit for approval.
* [ ] Cannot choose Cash/Credit.
* [ ] Cannot set selling prices.

### Manager

* [ ] Can review pending purchases.
* [ ] Can choose Cash or Credit.
* [ ] Can select cash account for cash purchases.
* [ ] Can confirm purchase.
* [ ] Can set selling prices by store location.
* [ ] Can perform the entire purchase flow without another user.

### Inventory

* [ ] Confirmed purchase increases Main Store stock.
* [ ] Purchase line items are tied to Stock.
* [ ] No inventory is received before confirmation.

### Accounting

* [ ] Credit purchase creates Accounts Payable.
* [ ] Cash purchase creates Cash Disbursement Voucher.
* [ ] Cash purchase records the corresponding accounting entry.
* [ ] No voucher is created for a credit purchase.

---

# 24. MVP Workflow

The final workflow is intentionally simple:

## Purchase Clerk

```text
CREATE
  ↓
ENTER SUPPLIER
  ↓
ENTER ITEMS
  ↓
ENTER COST
  ↓
SUBMIT
```

## Manager

```text
REVIEW
  ↓
CASH / CREDIT
  ↓
CONFIRM
  ↓
RECEIVE INTO MAIN STORE
  ↓
SET STORE PRICES
```

## Manager-created Purchase

```text
CREATE
  ↓
ENTER DETAILS
  ↓
CASH / CREDIT
  ↓
CONFIRM
  ↓
SET PRICES
```

The product should make this distinction clear:

> **The clerk records what was bought. The manager decides how it is paid and how it is sold.**
