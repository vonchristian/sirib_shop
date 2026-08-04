# PRD — User Roles, Permissions & Cash Account Assignment

**Product:** Sirib
**Status:** Draft
**Target:** Rails 8, designed for direct portability to Elixir/Phoenix
**Domain:** Users, Roles, Permissions, Treasury

---

## 1. Purpose

Define the operational roles available to a Sirib business and establish how users are granted permissions and assigned to cash accounts.

The initial roles are:

* `manager`
* `sales_clerk`
* `technician`
* `purchasing_clerk`

A `sales_clerk` may be assigned one or more `CashAccount` records, with an active cash account used for their cash sessions and cash transactions.

The design must support small SMEs where one employee may hold multiple roles.

---

# 2. Design Principles

### 2.1 Roles represent business responsibilities

Roles are not intended to represent every possible permission.

For example:

```text
sales_clerk
```

represents an employee who handles customer-facing sales and cashier responsibilities.

Fine-grained access should be controlled through permissions.

### 2.2 Users may have multiple roles

A user is not restricted to a single role.

Example:

```text
Maria
├── sales_clerk
└── purchasing_clerk
```

This supports small businesses where employees perform multiple functions.

### 2.3 Cash accounts are separate from users

A `CashAccount` represents where money is held or managed.

A user represents the employee responsible for operating the account.

Do not make `cash_account_id` a permanent attribute of `User`.

Instead, use an explicit assignment model.

---

# 3. Roles

## 3.1 Manager

The manager oversees business operations.

### Capabilities

* View business reports
* Manage users
* Assign roles
* Assign users to store locations
* Assign sales clerks to cash accounts
* Approve discounts
* Approve stock adjustments
* Approve spoilage
* Approve sensitive transactions
* View sales
* View purchasing
* View inventory
* View service operations
* View treasury
* View accounting
* Open/close or supervise cash sessions
* Void or reverse transactions according to business rules

---

# 4. Sales Clerk

The sales clerk handles both sales and cashier responsibilities.

### Capabilities

* Create and manage customers
* Create sales orders
* Process sales
* Process sales returns
* Receive customer payments
* Open cash sessions
* Close cash sessions
* Create cash receipt vouchers
* Create cash disbursement vouchers where permitted
* View assigned cash account
* View available inventory
* Create/modify carts
* Complete sales transactions
* View relevant customer balances

### Restrictions

A sales clerk must not:

* Modify accounting entries directly
* Delete posted transactions
* Modify stock quantities directly
* Change inventory valuation
* Modify another user's cash session
* Use an unassigned cash account
* Change their own role
* Assign themselves to another cash account

---

# 5. Technician

The technician performs repair/service operations.

### Capabilities

* View assigned work orders
* Create service notes
* Record diagnostics
* Update work-order status
* Create work-order tasks
* Record parts used
* Record service work
* Record received service items
* Record returned service items
* Complete assigned work orders
* View relevant customer and service-asset information

### Restrictions

A technician must not directly modify inventory quantities.

Parts consumed through a work order must create the appropriate inventory movement through the inventory/order workflow.

---

# 6. Purchasing Clerk

The purchasing clerk manages purchasing and inventory operations.

### Capabilities

* Manage suppliers
* Create purchase orders
* Receive purchases
* View inventory
* Manage stock transfers
* Perform stock counts
* Create spoilage orders
* Create internal-use orders
* Request inventory adjustments
* View purchasing history
* View supplier balances where permitted

### Restrictions

Inventory adjustments and spoilage may require manager approval depending on business configuration.

The purchasing clerk must not directly modify accounting entries.

---

# 7. User Roles

## User

A `User` belongs to a `Business`.

A user may have multiple roles.

Conceptually:

```text
Business
  │
  └── User
       ├── Role
       ├── Role
       └── StoreLocation
```

### Suggested models

```text
User
Role
UserRole
```

---

# 8. Role Model

`Role` represents a predefined business role.

```text
Role
----
id
name
```

Initial role names:

```text
manager
sales_clerk
technician
purchasing_clerk
```

Roles should be scoped to the Sirib business.

A business may assign roles to its users but should not create arbitrary system roles in the initial implementation.

---

# 9. UserRole

```text
UserRole
--------
id
user_id
role_id
```

Constraints:

```text
UNIQUE(user_id, role_id)
```

Example:

```text
User: Maria
Roles:
- sales_clerk
- purchasing_clerk
```

---

# 10. Store Location Assignment

Users should be assigned to one or more `StoreLocation` records.

Suggested model:

```text
UserStoreLocation
-----------------
id
user_id
store_location_id
```

Constraints:

```text
UNIQUE(user_id, store_location_id)
```

This is important because a multi-location business may have:

```text
Main Store
Branch A
Branch B
Branch C
```

A sales clerk should only operate within the locations assigned to them unless explicitly granted broader access.

---

# 11. Cash Account

A `CashAccount` belongs to the Treasury domain.

Examples:

```text
Main Cash
Branch A Cash
Branch B Cash
Petty Cash
GCash
Bank — BDO
Bank — BPI
```

The account represents a financial account used for actual money movement.

---

# 12. Cash Account Assignment

Do not put:

```text
users.cash_account_id
```

directly on `users`.

Instead create:

```text
CashAccountAssignment
---------------------
id
user_id
cash_account_id
assigned_at
unassigned_at
active
```

This provides an audit trail.

Example:

```text
Maria
  ↓
CashAccountAssignment
  ↓
Branch A Cash
```

Later:

```text
Maria
  ↓
CashAccountAssignment
  ↓
Main Cash
```

The previous assignment remains historically recorded.

---

# 13. Assignment Rules

Only authorized users, normally a `manager`, may assign a cash account to a sales clerk.

A user cannot assign a cash account to themselves.

The assigned cash account must belong to the same `Business` as the user.

If store-location restrictions are enabled, the cash account's location must be compatible with the user's assigned location.

---

# 14. Active Cash Account

A sales clerk may have multiple assigned cash accounts over time.

However, the system should identify the account available for their current cash session.

Example:

```text
Maria
Role: sales_clerk

Assigned:
✓ Branch A Cash
✓ Main Cash

Current Session:
Branch A Cash
```

The user should explicitly select the cash account when opening a session if multiple accounts are available.

---

# 15. Cash Session

A `CashSession` belongs to a `User` and a `CashAccount`.

```text
CashSession
-----------
id
user_id
cash_account_id
store_location_id
opened_at
closed_at
opening_amount
closing_amount
status
```

Status:

```text
open
closed
```

A user should normally have only one active cash session at a time.

Constraint:

```text
One open CashSession per User
```

The system may additionally enforce:

```text
One open CashSession per User + CashAccount
```

depending on the operational requirements.

---

# 16. Sales Transaction Flow

For a sales clerk:

```text
Login
  ↓
Select Store Location
  ↓
Select Assigned Cash Account
  ↓
Open Cash Session
  ↓
Create Sale
  ↓
Select Payment Method
  ↓
Create Cash Receipt Voucher
  ↓
Preview Voucher
  ↓
Confirm
  ↓
Create Accounting Entry
```

Example:

```text
Sales Order
₱10,000

Cash Account:
Branch A Cash
```

Voucher:

```text
Cash Receipt Voucher
CRV-000123

Cash Account:
Branch A Cash

Amount:
₱10,000
```

After confirmation:

```text
Debit   Branch A Cash       ₱10,000
Credit  Sales Revenue       ₱10,000
```

---

# 17. Cash Disbursement

If a sales clerk is permitted to make cash disbursements:

```text
Create Disbursement
  ↓
Cash Disbursement Voucher
  ↓
Preview
  ↓
Confirm
  ↓
Accounting Entry
```

Example:

```text
Dr Expense / Payable
Cr Branch A Cash
```

Businesses should be able to restrict cash disbursement capability to managers if required.

---

# 18. Cash Session Closing

At the end of a shift:

```text
Sales Clerk
   ↓
Close Cash Session
   ↓
System calculates expected cash
   ↓
User enters counted cash
   ↓
System calculates variance
   ↓
Confirm Closing
```

Example:

```text
Opening Cash       ₱5,000
Cash Receipts     ₱25,000
Cash Disbursements ₱2,000
Expected Cash     ₱28,000

Counted Cash      ₱27,500

Variance           -₱500
```

The system should preserve the variance.

A manager may be required to approve significant variances.

---

# 19. Permissions

Permissions should be represented separately from roles.

Example permissions:

```text
sales.view
sales.create
sales.return
sales.payment

treasury.session.open
treasury.session.close
treasury.voucher.create
treasury.voucher.confirm
treasury.voucher.cancel

inventory.view
inventory.receive
inventory.transfer
inventory.adjust
inventory.spoilage

purchasing.view
purchasing.create
purchasing.receive

service.view
service.create
service.update
service.complete

users.view
users.manage

accounting.view
```

Roles map to permissions.

Example:

```text
manager
  → all applicable permissions

sales_clerk
  → sales.*
  → treasury.session.*
  → treasury.voucher.create
  → treasury.voucher.confirm
  → customers.*

technician
  → service.*

purchasing_clerk
  → purchasing.*
  → inventory.view
  → inventory.receive
  → inventory.transfer
  → inventory.spoilage
```

---

# 20. Important Accounting Boundary

Users must never directly create or modify an `Accounting::Entry`.

The flow is:

```text
Operational Transaction
        ↓
Treasury Voucher
        ↓
Preview
        ↓
Confirm
        ↓
Accounting Entry
```

when a `CashAccount` is involved.

If no cash account is involved:

```text
Operational Transaction
        ↓
Accounting Entry
```

The resulting accounting entry is immutable once posted.

---

# 21. Auditability

The system should record:

```text
created_by
updated_by
confirmed_by
cancelled_by
created_at
updated_at
confirmed_at
cancelled_at
```

for relevant transactional records.

For cash-account assignments:

```text
assigned_at
assigned_by
unassigned_at
unassigned_by
```

This allows the business to answer:

> Who was responsible for this cash account at the time of the transaction?

---

# 22. Multi-Location Example

Business:

```text
ABC Computer Shop
```

Locations:

```text
Main Store
Branch 1
Branch 2
```

Users:

```text
Maria
  sales_clerk
  Branch 1

Pedro
  technician
  Branch 1

Juan
  purchasing_clerk
  Main Store

Ana
  manager
  all locations
```

Cash accounts:

```text
Main Store Cash
Branch 1 Cash
Branch 2 Cash
```

Assignments:

```text
Maria → Branch 1 Cash
```

When Maria opens her session:

```text
CashSession
User: Maria
Location: Branch 1
CashAccount: Branch 1 Cash
```

Every cash receipt created by Maria during that session uses the assigned account.

---

# 23. Security Rules

The backend must enforce permissions.

Do not rely solely on UI visibility.

For example, hiding the "Adjust Inventory" button is insufficient.

The server must reject:

```text
sales_clerk → inventory adjustment
technician → accounting entry creation
sales_clerk → assign cash account
sales_clerk → access another business's cash account
```

Every authorization check must be performed server-side.

---

# 24. Rails 8 Domain Organization

Recommended structure:

```text
app/domains/
├── businesses/
├── customers/
├── catalogs/
├── inventory/
├── orders/
├── services/
├── treasury/
└── accounting/
```

User/role functionality belongs under:

```text
businesses/
├── business.rb
├── user.rb
├── role.rb
├── user_role.rb
├── store_location.rb
├── user_store_location.rb
└── cash_account_assignment.rb
```

Treasury contains:

```text
treasury/
├── cash_account.rb
├── cash_session.rb
├── voucher.rb
└── voucher_amount_line.rb
```

This maintains the domain boundaries and remains straightforward to port to Phoenix contexts.

---

# 25. Acceptance Criteria

### Roles

* [ ] Business can have users.
* [ ] User can have multiple roles.
* [ ] Initial roles are manager, sales_clerk, technician, purchasing_clerk.
* [ ] Roles are business-scoped.
* [ ] Role permissions are enforced server-side.

### Store locations

* [ ] User can be assigned to one or more store locations.
* [ ] User cannot access another location unless authorized.

### Cash accounts

* [ ] Cash accounts belong to a business.
* [ ] Cash accounts may be associated with a store location.
* [ ] Sales clerks can be assigned cash accounts.
* [ ] Assignment has an audit history.
* [ ] Only authorized users can create/change assignments.
* [ ] Sales clerk cannot assign their own cash account.

### Cash sessions

* [ ] Sales clerk can open a session using an assigned cash account.
* [ ] Sales clerk cannot open a session against an unassigned cash account.
* [ ] Sales clerk can close their own session.
* [ ] Closing calculates expected versus counted cash.
* [ ] Variance is recorded.
* [ ] Manager approval can be required for significant variance.

### Vouchers

* [ ] Cash transactions create a voucher.
* [ ] Voucher can be previewed.
* [ ] Voucher can be confirmed.
* [ ] Voucher can be cancelled before confirmation.
* [ ] Confirmation creates the accounting entry.
* [ ] Posted accounting entries cannot be edited or deleted.
* [ ] Voucher records the cash account involved.

### Accounting

* [ ] Users cannot directly modify posted accounting entries.
* [ ] Accounting entries are created from confirmed financial transactions.
* [ ] Accounting entries retain the source transaction reference.
