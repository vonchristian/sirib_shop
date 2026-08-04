# PRD-001 --- Business, Organization, Users, Customers, Suppliers & Store Locations

## 1. Objective

Provide the organizational foundation for a multi-tenant retail and
repair platform.

The system must support a business with a main store/warehouse and
multiple branch locations, employees, customers, suppliers, and
organizational customers such as companies or government offices.

## 2. Domain model

``` text
Business
├── StoreLocation
├── User
├── Customer
├── Supplier
└── Product/Catalog/etc.
```

## 3. Business

A `Business` is the tenant and legal/operator boundary.

### Fields

``` text
id
name
legal_name
code
tax_identifier
email
phone
timezone
currency
status
created_at
updated_at
```

### Rules

-   Every business-owned record must belong to a business directly or
    through an owned parent.
-   Business code is unique.
-   A business must have exactly one main inventory receiving location
    before purchasing can be enabled.

## 4. StoreLocation

A `StoreLocation` represents a physical inventory location.

Examples:

``` text
Main Warehouse
Angeles Branch
Dau Branch
```

### Fields

``` text
id
business_id
name
code
location_type
is_main
address
status
created_at
updated_at
```

`location_type`:

``` text
warehouse
store
```

### Rules

-   `code` is unique within a business.
-   A business must have one and only one active main receiving
    location.
-   All purchases are received at the main location in MVP.
-   A branch does not receive supplier purchases directly.
-   Inventory exists only at a store location.

## 5. User

A `User` is a business employee/application user.

### Fields

``` text
id
business_id
name
email
password_digest
status
created_at
updated_at
```

Users may later have roles such as:

``` text
owner
manager
cashier
inventory_clerk
purchasing
technician
accountant
```

Use authorization/roles rather than hardcoding permissions into business
models.

## 6. Platform Admin

Use `AdminUser` only for platform-level operators who can access
multiple businesses.

``` text
PlatformAdmin
    ↓
Businesses
```

If administration is only elevated access inside one business, do not
create a separate model.

## 7. Customer

A `Customer` represents the commercial relationship with a buyer.

Customer may represent:

``` text
person
business
government
organization
office
department
```

### Fields

``` text
id
business_id
name
customer_type
code
email
phone
tax_identifier
status
parent_id
created_at
updated_at
```

`parent_id` provides organizational hierarchy.

Example:

``` text
City Government
└── Engineering Office
    └── Procurement Department
```

### Rules

-   A customer belongs to one business.
-   Customer code is unique within a business.
-   Parent must belong to the same business.
-   Circular customer hierarchies are prohibited.
-   A customer can place many sales orders and work orders.
-   A customer may also exist independently as a person or organization
    without a parent.

## 8. Supplier

A `Supplier` represents the commercial relationship with a vendor.

### Fields

``` text
id
business_id
name
supplier_type
code
email
phone
tax_identifier
status
created_at
updated_at
```

### Rules

-   Supplier belongs to one business.
-   Supplier code is unique within a business.
-   A supplier is not a customer automatically.
-   A future relationship layer may allow the same external organization
    to be both customer and supplier.

## 9. Acceptance criteria

-   Business can create its main location.
-   Business can create branch locations.
-   Business can create users.
-   Business can create customers including hierarchical
    government/company offices.
-   Business can create suppliers.
-   A customer cannot reference another business's customer as parent.
-   A supplier/customer cannot be accessed across tenant boundaries.
-   Only one active main location exists per business.
