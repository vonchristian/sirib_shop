# PRD — Multi-Location User Access

**Product:** Sirib
**Status:** Revised
**Scope:** Multi-location user access and active location context
**Target:** Rails 8, designed for direct portability to Elixir/Phoenix

---

# 1. Purpose

Allow a single Sirib `User` to access multiple `StoreLocation` records using one login account.

A user may be assigned to multiple locations, but operates within one **current store location** at a time.

The current location is **request/session context**, not persistent user data.

Sirib will use the Rails `Current` pattern:

```ruby
Current.user
Current.business
Current.store_location
```

When the user switches locations, the application updates the current context.

There is **no `current_store_location_id` column on `users`**.

---

# 2. Core Principle

> **One person = one User account. A User may be assigned to multiple StoreLocations. `Current.store_location` represents the location currently being operated in.**

The distinction is:

```text
UserStoreLocation
    ↓
Where the user is authorized to work

Current.store_location
    ↓
Where the user is currently working
```

---

# 3. User

The `User` model represents the employee.

```text
User
----
id
business_id
name
email
...
```

The User does **not** contain:

```text
current_store_location_id
```

The User has many authorized store locations through `UserStoreLocation`.

```ruby
class User < ApplicationRecord
  belongs_to :business

  has_many :user_store_locations
  has_many :store_locations,
           through: :user_store_locations
end
```

---

# 4. StoreLocation

```text
StoreLocation
-------------
id
business_id
name
code
address
active
```

A store location belongs to exactly one Business.

Example:

```text
ABC Computer Shop

Main Store
Branch A
Branch B
```

---

# 5. UserStoreLocation

This is the authorization relationship between a user and a store location.

```text
UserStoreLocation
-----------------
id
user_id
store_location_id
assigned_at
assigned_by
unassigned_at
unassigned_by
active
```

Relationships:

```ruby
class UserStoreLocation < ApplicationRecord
  belongs_to :user
  belongs_to :store_location
end
```

A user can have multiple assignments:

```text
Maria
 ├── Main Store
 ├── Branch A
 └── Branch B
```

---

# 6. Current Context

Sirib should use Rails' `Current` pattern.

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :business
  attribute :store_location
end
```

The current context represents the operating context of the current request.

Example:

```ruby
Current.user
# => Maria

Current.business
# => ABC Computer Shop

Current.store_location
# => Branch A
```

---

# 7. Why Current.store_location Is Not Stored on User

The current location is not an intrinsic property of the user.

Maria can be:

```text
09:00 → Branch A
13:00 → Branch B
17:00 → Branch A
```

Her identity has not changed.

Her authorized locations have not necessarily changed.

Only her **operating context** changed.

Therefore:

```text
User
    ≠
Current.store_location
```

The current location belongs to the current application context.

---

# 8. Login

When a user logs in:

### One assigned location

If the user has one active location:

```text
Maria
 └── Branch A
```

the application can automatically establish:

```ruby
Current.store_location = branch_a
```

### Multiple assigned locations

If the user has multiple locations:

```text
Maria
 ├── Main Store
 ├── Branch A
 └── Branch B
```

the application should require the user to select a location before beginning location-sensitive operations.

---

# 9. Switching Locations

When Maria switches from:

```text
Branch A
```

to:

```text
Branch B
```

the application changes:

```ruby
Current.store_location = branch_b
```

It does **not** update the User record.

There is no:

```ruby
current_user.update!(
  current_store_location_id: branch_b.id
)
```

---

# 10. Location Switch Authorization

The application must verify that the requested location is assigned to the current user.

Conceptually:

```ruby
authorized =
  current_user
    .store_locations
    .exists?(id: requested_location_id)
```

Only then:

```ruby
Current.store_location = requested_location
```

The user must not be able to set:

```ruby
Current.store_location
```

to an arbitrary location.

---

# 11. Recommended Location Switch Operation

Use a dedicated operation rather than directly setting `Current.store_location` throughout controllers.

Example:

```ruby
SwitchStoreLocation.call(
  user: Current.user,
  store_location: requested_location
)
```

Responsibilities:

1. Verify user authorization.
2. Verify the location belongs to the user's business.
3. Verify the location is active.
4. Verify there is no blocking active transaction/session.
5. Set `Current.store_location`.
6. Establish any related operational context.

---

# 12. Current Context Lifecycle

`Current` is request-scoped.

A typical request:

```text
HTTP Request
     ↓
Authenticate User
     ↓
Set Current.user
     ↓
Set Current.business
     ↓
Resolve Current.store_location
     ↓
Controller / Service
     ↓
Response
     ↓
Current automatically resets
```

Example:

```ruby
Current.user = user
Current.business = user.business
Current.store_location = store_location
```

At the end of the request, Rails resets `Current`.

---

# 13. Persistence of Selected Location

If the application wants the user to return to their last-used location after logging in again, this should be treated as a **UI preference**, not the authoritative current location.

For example, a separate preference could be introduced later:

```text
UserPreference
```

or:

```text
last_store_location_id
```

But this is not required for the initial implementation.

The authoritative operating context remains:

```ruby
Current.store_location
```

---

# 14. Transaction Location

Every location-sensitive transaction must persist its own location.

Example:

```text
SalesOrder
-----------
id
business_id
store_location_id
created_by_id
...
```

When Maria creates a sales order:

```ruby
SalesOrder.create!(
  business: Current.business,
  store_location: Current.store_location,
  created_by: Current.user
)
```

The order permanently records:

```text
Branch A
```

even if Maria later switches to Branch B.

---

# 15. Historical Integrity

Suppose:

```text
10:00
Current.store_location = Branch A
```

Maria creates:

```text
Sales Order #1001
```

The order contains:

```text
store_location_id = Branch A
```

At 13:00:

```text
Current.store_location = Branch B
```

Sales Order #1001 remains:

```text
Branch A
```

The transaction does not reference `Current` dynamically after creation.

---

# 16. Location-Scoped Queries

Location-sensitive operations should use the current context.

For example:

```ruby
SalesOrder.where(
  business: Current.business,
  store_location: Current.store_location
)
```

Inventory:

```ruby
Stock.where(
  business: Current.business,
  store_location: Current.store_location
)
```

Work orders:

```ruby
WorkOrder.where(
  business: Current.business,
  store_location: Current.store_location
)
```

However, managers with cross-location reporting permissions may explicitly query multiple locations.

---

# 17. Current Context Must Not Replace Authorization

`Current.store_location` is context.

It is **not** the security boundary by itself.

The application must still verify:

```text
Current.user
     ↓
authorized for
     ↓
Current.store_location
```

A malicious request must not be able to manipulate the current context to gain access to another location.

---

# 18. Cash Sessions

Cash sessions are tied to a location at the time they are opened.

```text
CashSession
-----------
id
user_id
store_location_id
cash_account_id
opened_at
closed_at
opening_amount
closing_amount
status
```

Opening:

```text
Current.user
      ↓
Current.store_location
      ↓
CashAccount
      ↓
CashSession
```

Example:

```text
Maria
Current.store_location = Branch A

Open Cash Session
→ Branch A Cash
```

The `CashSession` stores its own:

```text
store_location_id
```

It must not depend on `Current.store_location` after creation.

---

# 19. Cash Session and Location Switching

If Maria has an open cash session:

```text
Maria
Current.store_location = Branch A

CashSession
Branch A Cash
OPEN
```

she should not be allowed to switch to Branch B.

Required flow:

```text
Close Cash Session
        ↓
Switch Store Location
        ↓
Current.store_location = Branch B
        ↓
Open Branch B Cash Session
```

This prevents cash responsibility from becoming ambiguous.

---

# 20. Inventory

Inventory is location-specific.

Example:

```text
Product: iPhone 15

Main Store
10 units

Branch A
3 units

Branch B
5 units
```

With:

```ruby
Current.store_location = branch_a
```

normal inventory operations operate against Branch A.

The backend must still enforce authorization.

---

# 21. Transfer Orders

Transfer orders explicitly identify both locations.

```text
TransferOrder
-------------
origin_store_location_id
destination_store_location_id
```

Example:

```text
Main Store
    ↓
Transfer Order
    ↓
Branch A
```

The current location does not replace these fields.

The system validates the user's authorization for the relevant locations.

---

# 22. Work Orders

Work orders belong to a store location.

```text
WorkOrder
---------
store_location_id
customer_id
service_asset_id
...
```

When created:

```ruby
WorkOrder.create!(
  business: Current.business,
  store_location: Current.store_location
)
```

A technician assigned to multiple locations can switch their current location before operating on that location's work orders.

---

# 23. Sales Flow

Example:

```text
Login
  ↓
Select Branch A
  ↓
Current.store_location = Branch A
  ↓
Open Cash Session
  ↓
Create Sales Order
  ↓
Receive Payment
  ↓
Cash Receipt Voucher
  ↓
Preview
  ↓
Confirm
  ↓
Accounting Entry
```

Relevant records contain persistent references:

```text
user_id
store_location_id
cash_account_id
```

where appropriate.

---

# 24. User Roles

Roles remain independent of the current location.

Initial roles:

```text
manager
sales_clerk
technician
purchasing_clerk
```

Example:

```text
Maria
Roles:
- sales_clerk
- purchasing_clerk

Authorized locations:
- Main Store
- Branch A
- Branch B

Current:
Branch A
```

The role determines **what** Maria can do.

`UserStoreLocation` determines **where** she can do it.

`Current.store_location` determines **where she is currently operating**.

---

# 25. Manager

A manager may have access to multiple locations.

Example:

```text
Ana
Role:
manager

Authorized:
Main Store
Branch A
Branch B

Current:
Branch A
```

The manager can switch:

```ruby
Current.store_location = branch_b
```

when authorized.

Business-wide reporting may operate independently of the current location.

---

# 26. UI

The active location should be visible globally.

Example:

```text
┌─────────────────────────────┐
│ ABC Computer Shop           │
│                             │
│ 📍 Branch A              ▼  │
└─────────────────────────────┘
```

Location selector:

```text
Current Store Location

✓ Branch A
  Main Store
  Branch B
```

When the user selects Branch B:

```ruby
Current.store_location = branch_b
```

The application then operates under Branch B context.

---

# 27. Rails Architecture

Recommended `Current` implementation:

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :business
  attribute :store_location
end
```

Authentication establishes:

```ruby
Current.user = authenticated_user
Current.business = authenticated_user.business
```

Location selection establishes:

```ruby
Current.store_location = authorized_store_location
```

---

# 28. Avoid Global Mutable State

`Current` must remain request/thread safe through Rails' `ActiveSupport::CurrentAttributes`.

Do not implement:

```ruby
$CURRENT_STORE_LOCATION
```

or another global variable.

Do not store the active location permanently on `User`.

Use:

```ruby
Current.store_location
```

for the current request context.

---

# 29. Rails Controller Concern

A controller-level concern may establish the location context.

Conceptually:

```ruby
class ApplicationController < ActionController::Base
  before_action :set_current_context

  private

  def set_current_context
    Current.user = current_user
    Current.business = current_user.business
    Current.store_location = resolve_store_location
  end
end
```

The actual implementation should validate authorization before setting the location.

---

# 30. Phoenix/Ecto Portability

The architecture must not depend on Rails-specific database behavior.

The conceptual Phoenix equivalent is a request context containing:

```text
current_user
current_business
current_store_location
```

For example:

```text
conn.assigns.current_user
conn.assigns.current_business
conn.assigns.current_store_location
```

or an equivalent context mechanism.

The database remains:

```text
users
store_locations
user_store_locations
```

with no:

```text
users.current_store_location_id
```

required.

---

# 31. Database Relationships

```text
Business
  has_many :users
  has_many :store_locations

User
  belongs_to :business
  has_many :user_store_locations
  has_many :store_locations,
           through: :user_store_locations

StoreLocation
  belongs_to :business
  has_many :user_store_locations
  has_many :users,
           through: :user_store_locations
```

`Current.store_location` is **not a database relationship**.

It is runtime context.

---

# 32. Example

Business:

```text
ABC Computer Shop
```

Locations:

```text
Main Store
Branch A
Branch B
```

Maria:

```text
User:
Maria

Roles:
sales_clerk

Authorized Locations:
Main Store
Branch A
Branch B
```

Maria logs in:

```text
Current.user = Maria
Current.business = ABC Computer Shop
```

She selects:

```text
Branch A
```

The application establishes:

```text
Current.store_location = Branch A
```

Maria creates a sale.

The database stores:

```text
SalesOrder
----------------
created_by_id = Maria
store_location_id = Branch A
```

Later she switches:

```text
Current.store_location = Branch B
```

The existing Sales Order remains associated with Branch A.

---

# 33. Acceptance Criteria

## User access

* [ ] A user has one login identity.
* [ ] A user can be assigned to multiple StoreLocations.
* [ ] User-location assignments are auditable.
* [ ] A user cannot access an unauthorized location.

## Current context

* [ ] `Current` exposes `user`.
* [ ] `Current` exposes `business`.
* [ ] `Current` exposes `store_location`.
* [ ] There is no `current_store_location_id` on User.
* [ ] Current location is request/context scoped.
* [ ] Current location must be authorized for the current user.
* [ ] Current location must belong to the current user's business.

## Switching

* [ ] User can switch between assigned locations.
* [ ] Switching updates `Current.store_location`.
* [ ] Switching does not modify the User record.
* [ ] Unauthorized locations cannot be selected.
* [ ] Switching is blocked when an active cash session prevents it.

## Transactions

* [ ] Location-sensitive transactions persist their own `store_location_id`.
* [ ] New transactions default to `Current.store_location`.
* [ ] Historical transactions do not change when Current location changes.
* [ ] Backend authorization is enforced independently of the UI.

## Treasury

* [ ] CashSession stores its own `store_location_id`.
* [ ] CashSession uses `Current.store_location` when opened.
* [ ] Voucher operations use the active location context.
* [ ] Cash accounts are validated against the current location and user authorization.

---

# 34. Final Architecture

```text
                         Business
                            │
             ┌──────────────┴──────────────┐
             │                             │
           Users                     StoreLocations
             │                             │
             │      UserStoreLocation      │
             └─────────────┬───────────────┘
                           │
                           ↓
                  Authorized Locations
                           │
                           ↓
                 Current.store_location
                           │
              ┌────────────┼────────────┐
              ↓            ↓            ↓
            Sales       Inventory     Services
              │
              ↓
           Treasury
              │
         CashSession
              │
            Voucher
              │
              ↓
          Accounting
```

## Fundamental Rules

```text
User
  = Who is logged in

Role
  = What they are allowed to do

UserStoreLocation
  = Where they are authorized to work

Current.store_location
  = Where they are currently operating

Transaction.store_location_id
  = Where the transaction actually occurred

CashSession.store_location_id
  = Where the cash responsibility occurred
```

**The current location is runtime context, not user state.**
