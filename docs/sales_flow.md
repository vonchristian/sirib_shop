# PRD — Sales Transaction Flow

**Product:** Sirib
**Module:** Sales
**Status:** MVP — UX Revised
**Target:** Rails 8 + Hotwire + Stimulus
**Portability:** Elixir/Phoenix compatible domain design

---

# 1. Product Objective

Build a sales checkout experience that a new sales clerk can learn quickly and an experienced clerk can operate at high speed **without accidental transactions, incorrect quantities, wrong locations, or incorrect payments**.

The interface should behave like a purpose-built POS while remaining a server-rendered Rails application.

Primary technologies:

* Rails 8
* Hotwire
* Turbo
* Stimulus
* HTML forms
* Server-side validation

JavaScript should enhance the workflow rather than contain the business rules.

---

# 2. UX Principle

> **The system should prevent mistakes instead of asking the clerk to avoid making them.**

Do not rely on confirmation messages such as:

> "Are you sure?"

for every action.

Instead, structure the interface so incorrect actions are difficult or impossible.

Examples:

### Good

```text
Scan
 ↓
Product automatically appears
 ↓
Scan next item
```

### Bad

```text
Scan
 ↓
Open modal
 ↓
Select product
 ↓
Confirm
 ↓
Add
```

A physical sales counter needs speed.

---

# 3. Core UX Rules

The POS interface must:

1. Keep the scanner input ready.
2. Minimize mouse usage.
3. Make the current store location obvious.
4. Keep the cart visible.
5. Make the current total impossible to miss.
6. Clearly distinguish Cash and Credit.
7. Never allow an accidental duplicate sale.
8. Never silently change quantities.
9. Never silently change prices.
10. Never silently switch locations.
11. Require confirmation only at important irreversible points.
12. Preserve the cart when validation fails.
13. Provide clear recovery paths.

---

# 4. Main Screen

The primary sales screen should be a single workspace.

```text id="x5f2p0"
┌──────────────────────────────────────────────────────────┐
│ Sirib                         📍 Main Store     Maria     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ Scan or search product                                   │
│ [ 🔍 Scan barcode / search...                       ]    │
│                                                          │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ CART                                                 │ │
│ │                                                      │ │
│ │ Laptop Bag          1 × ₱1,500          ₱1,500      │ │
│ │ Logitech Mouse      2 × ₱800            ₱1,600      │ │
│ │ USB-C Cable         1 × ₱350              ₱350      │ │
│ │                                                      │ │
│ └──────────────────────────────────────────────────────┘ │
│                                                          │
│ Customer: Walk-in Customer                               │
│                                                          │
│                              TOTAL                       │
│                           ₱3,450                          │
│                                                          │
│                    [ CHECKOUT ]                           │
└──────────────────────────────────────────────────────────┘
```

The clerk should spend most of the transaction on this screen.

---

# 5. Scanner-First Interaction

The barcode input should automatically receive focus when the sales screen loads.

Example:

```text id="3e2p7v"
[ Scan barcode / search product... ]
        ↑
     autofocus
```

After scanning:

```text id="kq2zoc"
Barcode
   ↓
Stimulus receives scanner input
   ↓
Request product
   ↓
Turbo updates cart
   ↓
Input remains focused
```

The clerk should be able to continuously scan:

```text id="sp4m3k"
Scan
Scan
Scan
Scan
Scan
```

without clicking between products.

---

# 6. Barcode Scanner Behavior

Most physical barcode scanners behave as keyboard input devices.

Stimulus should detect the completed scanner input and submit the lookup.

Conceptually:

```text id="5nj5d5"
scanner
   ↓
keydown/input
   ↓
Stimulus controller
   ↓
Turbo request
```

The controller should not contain inventory or pricing rules.

It only handles:

* input
* focus
* keyboard behavior
* UI state

The server determines:

* product
* price
* stock
* availability
* authorization

---

# 7. Product Found

When a barcode matches exactly one ProductVariant:

```text id="8m3q47"
Barcode:
4801234567890

Product found:
Kingston 480GB SSD

Price:
₱2,500

Available:
8
```

The system should automatically add it to the cart.

No confirmation modal.

---

# 8. Duplicate Product Scan

If the same product is scanned twice:

```text id="0uh8gl"
Scan:
Kingston SSD

Cart:
Kingston SSD × 1
```

Second scan:

```text id="v5y2r0"
Kingston SSD × 2
```

Do not create:

```text id="xvby0p"
Kingston SSD × 1
Kingston SSD × 1
```

unless there is a domain-specific reason to do so.

This reduces clutter and prevents quantity errors.

---

# 9. Unknown Barcode

If the barcode is not found:

```text id="flj4t3"
┌─────────────────────────────┐
│ Product not found           │
│                             │
│ Barcode: 4801234567890      │
│                             │
│ [ Search Products ]         │
│ [ Cancel ]                  │
└─────────────────────────────┘
```

The scanner input remains available.

The clerk can search manually without losing the cart.

---

# 10. Search

The same input should support both:

```text id="0gj8cs"
Barcode
```

and:

```text id="9g3qpr"
Text Search
```

Example:

```text id="rb75sp"
Search:
"Kingston"
```

Results appear immediately using Turbo Frames.

```text id="1e2ftt"
Kingston 480GB SSD
₱2,500
8 available

Kingston 1TB SSD
₱4,200
3 available

Kingston 16GB RAM
₱2,100
6 available
```

Clicking a result adds it to the cart.

---

# 11. Turbo Frames

The sales screen should be divided into independent Turbo Frames.

Conceptually:

```text id="0x1y5r"
Sales Screen

├── product_search
├── cart
├── customer
├── totals
└── checkout
```

Updating the cart should not reload the entire page.

Example:

```text id="0p5lvi"
Scan Product
     ↓
Turbo request
     ↓
Replace cart frame
     ↓
Update totals
```

---

# 12. Cart Updates

When an item is added:

```text id="4sp7h4"
Turbo Frame:
cart
```

updates.

The rest of the interface remains intact.

The scanner input should retain focus.

---

# 13. Quantity Editing

The cart should provide simple controls:

```text id="3mt7wl"
Kingston SSD

[-]   2   [+]

₱2,500 each
₱5,000
```

The clerk can:

```text id="e5mt4h"
+
-
```

or use the keyboard.

The server validates the resulting quantity.

---

# 14. Prevent Invalid Quantity

If available stock is:

```text id="7ndj9g"
3
```

and the clerk attempts:

```text id="q6x9h5"
quantity = 4
```

the interface should immediately explain:

```text id="wjv2td"
Only 3 available at Main Store.
```

Do not allow the cart to enter an invalid state.

---

# 15. Removing Items

Remove should be easy:

```text id="jcvq58"
[ × ]
```

For accidental removal, provide a short undo action rather than requiring a confirmation modal.

Example:

```text id="fyq7l2"
USB-C Cable removed.

[ Undo ]
```

This is faster and safer than:

```text id="r8d6w9"
Are you sure?
[Yes] [No]
```

---

# 16. Customer Selection

Customer selection should remain optional for normal cash sales.

Display:

```text id="i7l7nf"
Customer
[ Walk-in Customer ▼ ]
```

Clicking opens a Turbo Frame search.

```text id="v4p6sj"
Search customer
[ ABC Computer Services ]

Results:
ABC Computer Services
Juan Dela Cruz
XYZ Trading
```

Selecting a customer updates only the customer frame.

---

# 17. Credit Sale UX

Credit should force the clerk through the required customer step.

If the clerk selects:

```text id="nq9qjj"
CREDIT
```

without a customer:

```text id="h8r8q8"
Customer required for credit sale.

[ Select Customer ]
```

The system should not allow confirmation.

---

# 18. Checkout

The checkout button should always show the current amount.

```text id="d0ksn7"
┌───────────────────────────┐
│                           │
│ TOTAL                     │
│ ₱12,500                   │
│                           │
│ [ CHECKOUT ]              │
│                           │
└───────────────────────────┘
```

The button should be visually dominant.

---

# 19. Checkout Screen

Checkout should be deliberately simple.

```text id="3v9xqm"
CHECKOUT

Total
₱12,500

Payment Method

┌───────────────┐  ┌───────────────┐
│     CASH      │  │    CREDIT     │
└───────────────┘  └───────────────┘
```

Do not display unnecessary accounting terminology to the sales clerk.

The clerk should not need to understand:

* debit
* credit account
* journal entry
* voucher
* ledger

Those are system-level concepts.

---

# 20. Cash Checkout

Selecting Cash:

```text id="n6r8xh"
CASH

Total
₱12,500

Amount Received
[ 15,000 ]

Change
₱2,500

[ COMPLETE SALE ]
```

The change should update instantly with Stimulus.

Example:

```text id="ej6u1n"
Amount Received: ₱20,000

Change: ₱7,500
```

But the server remains authoritative when the transaction is submitted.

---

# 21. Cash Shortfall

If:

```text id="z18vpc"
Total:
₱12,500

Received:
₱10,000
```

display:

```text id="x8o2r7"
Remaining:
₱2,500
```

and disable:

```text id="z8g6yk"
[ COMPLETE SALE ]
```

The user should immediately understand what is wrong.

---

# 22. Credit Checkout

Selecting Credit:

```text id="8q0vci"
CREDIT

Customer
ABC Computer Services

Amount Due
₱12,500

[ COMPLETE SALE ]
```

If no customer exists:

```text id="x7d9ck"
Customer required
```

and the completion button remains disabled.

---

# 23. Payment Method Selection

Only one payment method can be selected in MVP.

```text id="2g5q9c"
○ CASH

○ CREDIT
```

No split payment interface.

Do not show:

```text id="b1c0l8"
Cash ₱5,000
GCash ₱5,000
Credit ₱2,500
```

until split payments are actually supported.

---

# 24. Final Confirmation

The final confirmation should be deliberately explicit because this action creates financial and inventory effects.

```text id="k8x3h4"
┌──────────────────────────────────────┐
│ CONFIRM SALE                          │
│                                      │
│ Location                             │
│ Main Store                           │
│                                      │
│ Items                                │
│ Laptop × 1                 ₱45,000   │
│ Bag × 1                    ₱1,500    │
│                                      │
│ TOTAL                       ₱46,500  │
│                                      │
│ PAYMENT                              │
│ Credit                              │
│ Customer: ABC Computer Services      │
│                                      │
│ [ BACK ]          [ CONFIRM SALE ]  │
└──────────────────────────────────────┘
```

The button should explicitly say:

> **Confirm Sale**

not:

> Submit

or:

> Save

---

# 25. Double-Click Protection

When the clerk clicks:

```text id="t4yqz9"
CONFIRM SALE
```

Stimulus immediately disables the button:

```text id="q9n6qf"
[ Processing... ]
```

The server must additionally enforce idempotency.

Both layers are required.

---

# 26. Successful Completion

After successful confirmation:

```text id="c1c7jq"
SALE COMPLETE

SO-10025

₱46,500

Payment:
CREDIT

Customer:
ABC Computer Services

[ PRINT RECEIPT ]

[ NEW SALE ]
```

The most important action should be:

```text id="1gd9z0"
[ NEW SALE ]
```

so the clerk can immediately serve the next customer.

---

# 27. Error Handling

Errors should appear where they matter.

Bad:

```text id="plb0gk"
Something went wrong.
```

Good:

```text id="wz9qph"
Unable to complete sale.

Kingston 480GB SSD is no longer
available at Main Store.

Available:
0

[ RETURN TO CART ]
```

The cart must remain intact whenever possible.

---

# 28. Stock Race Condition

Stimulus may show:

```text id="9h5k6x"
Available: 1
```

but another clerk may sell the item before confirmation.

Therefore:

```text id="7r3mkw"
UI validation
+
Server validation
```

are both required.

The final confirmation must recheck stock inside the transaction.

---

# 29. Location Indicator

The current location should always be visible.

```text id="xq3n9s"
📍 Main Store
```

The clerk should not need to open a settings screen to determine where they are operating.

If the user switches:

```text id="n5o3g8"
📍 Branch A
```

the location indicator changes immediately.

---

# 30. Preventing Wrong-Location Sales

If the user switches locations while a cart exists, do not silently move the cart.

Recommended behavior:

```text id="uhw2w7"
Current Cart

This sale was started at:
Main Store

You are switching to:
Branch A

What would you like to do?

[ Complete/Save Cart ]
[ Cancel Cart ]
[ Stay at Main Store ]
```

For MVP, the safest implementation is:

> **Do not allow location switching while an active cart exists.**

The clerk must finish or cancel the cart first.

This prevents accidental sales against the wrong store inventory.

---

# 31. Keyboard-First Operation

A senior clerk should be able to operate the majority of the POS without reaching for the mouse.

Suggested shortcuts:

```text id="3a6g6z"
F2     Focus product search/scanner
F4     Focus customer
F8     Checkout
Esc    Close current overlay
Enter  Select/confirm focused action
+      Increase quantity
-      Decrease quantity
```

Exact key mappings can be adjusted after usability testing.

The scanner input remains the default focus.

---

# 32. Stimulus Controllers

Keep controllers small and focused.

Recommended controllers:

```text id="4k5v0p"
product_search_controller
cart_controller
quantity_controller
payment_controller
customer_search_controller
checkout_controller
location_controller
```

Do not create one giant:

```text id="h1yq6f"
sales_controller.js
```

containing the entire POS.

---

# 33. Stimulus Responsibilities

Stimulus should handle:

* Focus
* Keyboard shortcuts
* Instant calculations for UX
* Button state
* Showing/hiding UI
* Scanner input
* Payment amount display
* Change calculation
* Loading indicators
* Preventing repeated clicks

Stimulus should **not** be responsible for:

* Final prices
* Stock authorization
* Inventory deduction
* Accounting
* Customer credit validation
* Creating vouchers
* Creating accounting entries

Those remain server-side.

---

# 34. Turbo Responsibilities

Turbo should handle:

* Cart updates
* Product search results
* Customer search
* Checkout transitions
* Validation responses
* Receipt rendering
* Cart updates after scanning

The application should avoid full-page reloads during normal sales operation.

---

# 35. Server Responsibilities

The Rails application remains the source of truth.

The server determines:

```text id="6h1wvl"
Current User
Current Business
Current Store Location
Product
Product Variant
Price
Stock
Customer
Cart
Payment
Sales Order
Voucher
Accounting Entry
```

The browser only provides input.

---

# 36. Transaction Boundary

Final sale confirmation should execute as one database transaction.

Conceptually:

```ruby id="w0g8d4"
ActiveRecord::Base.transaction do
  validate_cart!
  validate_stock!
  validate_payment!

  sales_order = create_sales_order!
  create_line_items!
  deduct_stock!

  create_voucher_if_cash!
  create_accounting_entry!

  complete_sale!
end
```

If anything fails:

```text id="qj1a7x"
ROLLBACK
```

The sale is not completed.

---

# 37. Cash Sale Flow

```text id="87js1h"
Scan
 ↓
Cart
 ↓
Checkout
 ↓
Cash
 ↓
Enter amount
 ↓
Change calculated
 ↓
Review
 ↓
Confirm
 ↓
Sales Order
 ↓
Cash Receipt Voucher
 ↓
Accounting Entry
 ↓
Inventory Deduction
 ↓
Receipt
```

---

# 38. Credit Sale Flow

```text id="hlz3pu"
Scan
 ↓
Cart
 ↓
Checkout
 ↓
Credit
 ↓
Select Customer
 ↓
Review
 ↓
Confirm
 ↓
Sales Order
 ↓
Accounts Receivable Entry
 ↓
Inventory Deduction
 ↓
Receipt
```

No voucher is created.

---

# 39. Visual Hierarchy

The sales screen should prioritize:

```text id="h1j7n3"
1. Scanner/Search
2. Cart
3. Total
4. Checkout
```

Secondary information:

```text id="x4n1kp"
Customer
Location
Clerk
```

Accounting details should remain hidden from the clerk.

---

# 40. Error Prevention Checklist

Before completing a sale, the system verifies:

```text id="h6u3f8"
✓ User authorized for location
✓ Current store location active
✓ Cart belongs to current location
✓ Cart contains items
✓ Products still exist
✓ Prices valid
✓ Quantities valid
✓ Stock available
✓ Customer valid for credit
✓ Cash session open for cash
✓ Cash amount sufficient
✓ Sale not already completed
```

Only then:

```text id="6s5j9c"
CONFIRM SALE
```

is allowed.

---

# 41. Accessibility and Physical Counter Use

The interface should support:

* Keyboard navigation
* Large click targets
* Clear labels
* High-contrast status indicators
* Minimal modal usage
* No hover-only actions
* Fast response after scanning
* Clear success/failure states

The interface should remain usable on:

* Desktop
* Laptop
* POS touchscreen

---

# 42. Performance Target

The perceived scan-to-cart experience should be extremely fast.

Target:

```text id="6e4k8h"
Scan
 ↓
Product identified
 ↓
Cart updated
```

should normally feel instantaneous to the clerk.

Avoid unnecessary full-page requests.

Use Turbo Frames and focused partial updates.

---

# 43. Acceptance Criteria

## Scanner

* [ ] Scanner input receives focus automatically.
* [ ] Barcode can be scanned without clicking.
* [ ] Successful scan adds product to cart.
* [ ] Repeated scan increments quantity.
* [ ] Unknown barcode produces a clear recovery path.
* [ ] Focus returns to scanner after adding an item.

## Cart

* [ ] Cart remains visible while searching.
* [ ] Quantity can be changed quickly.
* [ ] Invalid quantities cannot be confirmed.
* [ ] Items can be removed.
* [ ] Cart updates without full-page reload.
* [ ] Totals update immediately.

## Checkout

* [ ] Checkout clearly displays total.
* [ ] Cash and Credit are clearly separated.
* [ ] Cash displays change.
* [ ] Cash cannot complete with insufficient payment.
* [ ] Credit requires a customer.
* [ ] Only supported payment methods are displayed.

## Confirmation

* [ ] Final confirmation clearly shows location.
* [ ] Final confirmation clearly shows total.
* [ ] Final confirmation clearly shows payment method.
* [ ] Confirm button becomes disabled while processing.
* [ ] Duplicate submission cannot create duplicate transactions.
* [ ] Server performs final stock validation.

## Location

* [ ] Current store location is always visible.
* [ ] User cannot switch to an unauthorized location.
* [ ] User cannot switch location with an active cart.
* [ ] Transactions persist their location independently of `Current.store_location`.

## Completion

* [ ] Successful sale displays confirmation.
* [ ] Receipt can be printed.
* [ ] User can immediately start a new sale.
* [ ] Failed sales preserve the cart whenever possible.

---

# 44. Final UX Architecture

```text id="1u4c1f"
                    Current Context
                         │
              Current.store_location
                         │
                         ↓
                 ┌──────────────┐
                 │ SALES SCREEN │
                 └──────┬───────┘
                        │
              ┌─────────┴─────────┐
              ↓                   ↓
        Scanner/Search         Customer
              │                   │
              └─────────┬─────────┘
                        ↓
                       Cart
                        │
                        ↓
                    Checkout
                        │
               ┌────────┴────────┐
               ↓                 ↓
             CASH              CREDIT
               │                 │
         Cash Session        Customer
               │                 │
               ↓                 ↓
        Cash Receipt        Accounts
           Voucher          Receivable
               │                 │
               └────────┬────────┘
                        ↓
                 Accounting Entry
                        │
                        ↓
                 Inventory Effect
                        │
                        ↓
                  Sales Complete
                        │
                        ↓
                     Receipt
```

---

# 45. Product Requirement

**Hotwire and Stimulus are part of the product experience, not merely implementation choices.**

The sales clerk should experience Sirib as a **fast POS application** even though the underlying application is Rails server-rendered.

The desired interaction is:

> **Scan → See → Review → Pay → Confirm → Done**

with the system actively preventing common mistakes rather than requiring the clerk to understand the underlying accounting, inventory, or technical workflow.
