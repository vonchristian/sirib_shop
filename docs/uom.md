# PRD — Unit of Measurement

## 1. Objective

Allow a Product to be purchased, stocked, sold, returned, transferred, or internally consumed using different Units of Measurement while maintaining a single **Base Unit** for inventory.

Examples:

```text
UTP Cable
Base Unit: meter
1 box = 305 meters

Sugar
Base Unit: kilogram
1 sack = 50 kilograms
```

The system always maintains inventory in the Product's Base Unit.

---

# 2. Core Principle

Every Product has exactly one Base Unit.

All transaction quantities are converted to the Base Unit before affecting stock.

```text
Transaction Quantity
        ↓
Product Unit
        ↓
Conversion Quantity
        ↓
Base Quantity
        ↓
Stock.quantity
```

Example:

```text
Purchase:
2 sacks of sugar

1 sack = 50 kg

Base Quantity:
100 kg

Stock:
+100 kg
```

---

# 3. UnitOfMeasurement

A reusable Unit of Measurement definition.

```text
UnitOfMeasurement
-----------------
id
name
abbreviation
```

Examples:

```text
Piece       pcs
Kilogram    kg
Gram        g
Liter       L
Meter       m
Box         box
Sack        sack
Roll        roll
```

A UnitOfMeasurement does not contain product-specific conversion information.

The conversion belongs to the Product's use of that unit.

---

# 4. Product Base Unit

Every Product has one Base Unit.

```text
Product
-------
id
name
base_unit_id
```

Examples:

```text
Sugar
Base Unit: kg

UTP Cable
Base Unit: meter

Laptop
Base Unit: piece
```

The Base Unit is the unit in which inventory is maintained.

---

# 5. ProductUnit

A Product can have multiple transaction units.

```text
ProductUnit
-----------
id
product_id
unit_of_measurement_id

conversion_quantity

purchasable
sellable
```

`conversion_quantity` means:

> **1 ProductUnit equals X Base Units.**

Example:

```text
Sugar

Base Unit:
kg

ProductUnit:
sack

conversion_quantity:
50
```

Meaning:

```text
1 sack = 50 kg
```

---

# 6. Base Product Unit

The Product's Base Unit has a conversion quantity of:

```text
1
```

Example:

```text
Sugar

kg
conversion_quantity = 1
```

Therefore:

```text
1 kg = 1 kg
```

---

# 7. Example — Sugar

Product:

```text
Sugar
```

Base Unit:

```text
kg
```

Product Units:

```text
kg
conversion_quantity = 1
sellable = true
purchasable = true

sack
conversion_quantity = 50
sellable = true
purchasable = true
```

---

# 8. Sugar Purchase

Purchase:

```text
10 sacks
```

Conversion:

```text
10 × 50 kg
= 500 kg
```

PurchaseLineItem stores:

```text
quantity = 10
product_unit = sack
base_quantity = 500
```

Stock increases:

```text
+500 kg
```

---

# 9. Sugar Retail Sale

Customer buys:

```text
2.5 kg
```

SalesLineItem stores:

```text
quantity = 2.5
product_unit = kg
base_quantity = 2.5
```

Stock decreases:

```text
-2.5 kg
```

If stock was:

```text
500 kg
```

remaining stock becomes:

```text
497.5 kg
```

---

# 10. Example — UTP Cable

Product:

```text
UTP Cable CAT6
```

Base Unit:

```text
meter
```

Product Units:

```text
meter
conversion_quantity = 1

box
conversion_quantity = 305
```

Purchase:

```text
5 boxes
```

Base quantity:

```text
5 × 305
= 1,525 meters
```

Stock:

```text
1,525 meters
```

Sale:

```text
25 meters
```

Remaining:

```text
1,500 meters
```

---

# 11. Product Unit Conversion

The conversion formula is:

```text
base_quantity =
quantity × product_unit.conversion_quantity
```

Example:

```text
quantity = 3
unit = sack
conversion_quantity = 50

base_quantity = 150 kg
```

The conversion is performed when the transaction is confirmed/posted.

---

# 12. Historical Base Quantity

Inventory-affecting line items must store the converted Base Quantity.

Recommended fields:

```text
SalesLineItem
-------------
quantity
product_unit_id
base_quantity
```

```text
PurchaseLineItem
----------------
quantity
product_unit_id
base_quantity
```

Example:

```text
PurchaseLineItem

quantity:
2

unit:
sack

base_quantity:
100 kg
```

This preserves historical accuracy.

---

# 13. Why Base Quantity Is Stored

Suppose:

```text
Today:
1 sack = 50 kg
```

A customer purchases:

```text
2 sacks
```

The transaction records:

```text
base_quantity = 100 kg
```

If the ProductUnit configuration is later changed:

```text
1 sack = 40 kg
```

the historical transaction remains:

```text
100 kg
```

It must not be recalculated using the new conversion.

---

# 14. Decimal Quantities

The system must support decimal quantities.

This is required for retail products such as:

```text
Sugar:
2.5 kg

Rice:
3.75 kg

Cable:
12.5 meters

Oil:
1.5 liters
```

Therefore:

```text
quantity
base_quantity
conversion_quantity
```

must support decimal values.

Do not use integer-only quantities.

---

# 15. Inventory Storage

Stock continues to use:

```text
Stock
-----
product_id
store_location_id
quantity
```

`Stock.quantity` is always expressed in the Product's Base Unit.

Example:

```text
Sugar
Base Unit: kg

Stock:
497.5 kg
```

Not:

```text
9.95 sacks
```

The stock balance is always maintained in the Base Unit.

---

# 16. Purchase

A PurchaseLineItem may use any ProductUnit marked as purchasable.

Example:

```text
Sugar

Purchase:
10 sacks
```

System calculates:

```text
10 × 50
= 500 kg
```

Then:

```text
Stock.quantity += 500
```

Creating a purchase order does not increase stock.

Stock increases only when the purchase is received/posted according to the Purchase flow.

---

# 17. Sales

A SalesLineItem may use any ProductUnit marked as sellable.

Example:

```text
Sugar

Sale:
2.5 kg
```

System calculates:

```text
2.5 × 1
= 2.5 kg
```

Then:

```text
Stock.quantity -= 2.5
```

---

# 18. Sales Using Larger Units

A product can also be sold using its larger transaction unit.

Example:

```text
Sugar

Sale:
1 sack
```

Conversion:

```text
1 × 50
= 50 kg
```

Stock decreases by:

```text
50 kg
```

Therefore the same Product supports:

```text
1 sack
2.5 kg
500 g
```

provided those units are configured as valid ProductUnits.

---

# 19. Purchasing and Selling Units Are Independent

A ProductUnit can be:

```text
purchasable
sellable
```

Example:

```text
Sugar

kg:
purchasable = false
sellable = true

sack:
purchasable = true
sellable = true
```

This allows:

```text
Supplier → 50 kg sack
Customer → kilograms
```

without requiring the business to purchase individual kilograms.

---

# 20. Inventory Transactions

The same conversion mechanism applies to all inventory-affecting operations.

### Sales

```text
SalesLineItem
→ base_quantity
→ Stock decreases
```

### Sales Returns

```text
SalesReturnLineItem
→ base_quantity
→ Stock increases
```

### Purchases

```text
PurchaseLineItem
→ base_quantity
→ Stock increases
```

### Purchase Returns

```text
PurchaseReturnLineItem
→ base_quantity
→ Stock decreases
```

### Transfers

```text
TransferOrderLineItem
→ base_quantity
→ Source Stock decreases
→ Destination Stock increases
```

### Spoilage

```text
SpoilageOrderLineItem
→ base_quantity
→ Stock decreases
```

### Internal Use

```text
InternalUseOrderLineItem
→ base_quantity
→ Stock decreases
```

---

# 21. Returns

Returns use the same ProductUnit configuration.

Example:

```text
Customer returns:
1 sack of sugar
```

Conversion:

```text
1 × 50
= 50 kg
```

Stock increases:

```text
+50 kg
```

Purchase return:

```text
1 sack
```

Stock decreases:

```text
-50 kg
```

---

# 22. Transfers

Transfers use the same conversion.

Example:

```text
Transfer:
2 boxes of UTP Cable

1 box = 305 meters
```

Base quantity:

```text
610 meters
```

Source:

```text
-610 meters
```

Destination:

```text
+610 meters
```

The source and destination Stock updates must occur in the same database transaction.

---

# 23. Internal Use

Internal Use also uses ProductUnits.

Example:

```text
Repair Work Order

Internal Use:
2 meters of UTP Cable
```

Base quantity:

```text
2 meters
```

Stock:

```text
-2 meters
```

Or:

```text
Internal Use:
1 box
```

Stock:

```text
-305 meters
```

---

# 24. Pricing

Unit conversion and pricing are separate concerns.

Example:

```text
Sugar

1 sack = 50 kg

Price:
₱2,500 / sack
₱55 / kg
```

The conversion determines inventory quantity.

The pricing configuration determines the selling price.

Do not automatically derive one price from another.

---

# 25. Store-Specific Pricing

Because pricing is Store Location-specific, the ProductUnit can be used by the existing pricing model.

Example:

```text
Main Branch

Sugar:
₱55 / kg
₱2,500 / sack
```

Another Store Location may have different prices.

The UOM domain defines the unit and conversion.

The pricing domain defines the price.

---

# 26. Transaction Display

The transaction should display the quantity in the unit selected by the user.

Example:

```text
Sales Order

Sugar
2.5 kg × ₱55
₱137.50
```

Purchase:

```text
Purchase

Sugar
10 sacks × ₱2,500
₱25,000
```

The system internally records:

```text
Sugar
Base Quantity: 500 kg
```

---

# 27. Reporting

Reports should be able to show both the entered quantity and Base Quantity.

Example:

```text
Purchase Report

Product     Qty    Unit     Base Qty
-------------------------------------
Sugar       10     sack     500 kg
UTP Cable    5     box      1,525 m
```

Sales:

```text
Sales Report

Product     Qty    Unit     Base Qty
-------------------------------------
Sugar       2.5    kg       2.5 kg
UTP Cable   25     m        25 m
```

Stock:

```text
Stock Report

Product       Base Unit    Quantity
-----------------------------------
Sugar         kg           497.5
UTP Cable     m            1,500
```

---

# 28. Validation

The system must validate:

### Product

* Must have exactly one Base Unit.

### ProductUnit

* Must belong to a Product.
* Must reference a UnitOfMeasurement.
* `conversion_quantity` must be greater than zero.
* Base ProductUnit must have conversion quantity of `1`.

### Transaction

* Quantity must be greater than zero.
* ProductUnit must belong to the same Product.
* ProductUnit must be allowed for the transaction type.
* Conversion must produce a valid Base Quantity.

---

# 29. Base Unit Changes

Once a Product has inventory or historical transactions, its Base Unit must not be changed.

For example:

```text
Sugar
Base Unit: kg
```

cannot later become:

```text
Base Unit: sack
```

because all existing inventory and transaction history are expressed in kilograms.

If the business genuinely needs a different base unit, create a new Product or perform a controlled migration/stock conversion process outside normal Product editing.

---

# 30. ProductUnit Changes

The conversion quantity may be changed only for future transactions.

Example:

```text
Old:
1 sack = 50 kg
```

New supplier packaging:

```text
1 sack = 25 kg
```

Future transactions use:

```text
25 kg
```

Existing transactions retain their stored:

```text
base_quantity
```

---

# 31. No Generic Conversion Matrix

Do not create a general-purpose system like:

```text
kg → sack
sack → box
box → gram
meter → roll
roll → box
```

Instead, every ProductUnit simply defines:

```text
1 ProductUnit = X Base Units
```

Example:

```text
Sugar
Base: kg

sack = 50 kg
```

and:

```text
UTP Cable
Base: meter

box = 305 meters
```

This keeps the domain simple.

---

# 32. MVP Scope

## Included

* UnitOfMeasurement
* Product Base Unit
* ProductUnit
* Conversion Quantity
* Purchasable flag
* Sellable flag
* Decimal quantities
* Base Quantity on transaction lines
* Purchase conversion
* Sales conversion
* Sales return conversion
* Purchase return conversion
* Transfer conversion
* Spoilage conversion
* Internal Use conversion
* Base-unit stock
* Unit-aware transaction display
* Unit-aware reporting
* Historical conversion preservation
* Store-specific pricing using ProductUnit

## Excluded

* Generic conversion matrix
* Automatic price conversion
* Nested packaging
* Multiple base units
* Unit formulas
* Complex dimensions
* Automatic unit conversion between unrelated products
* Advanced packaging management

---

# 33. Final Data Model

```text
UnitOfMeasurement
-----------------
id
name
abbreviation
```

```text
Product
-------
id
name
base_unit_id
```

```text
ProductUnit
-----------
id
product_id
unit_of_measurement_id

conversion_quantity

purchasable
sellable
```

Inventory line items:

```text
SalesLineItem
-------------
quantity
product_unit_id
base_quantity
```

```text
PurchaseLineItem
----------------
quantity
product_unit_id
base_quantity
```

The same pattern applies to other inventory-affecting line items.

---

# 34. Final Business Rule

The entire UOM system can be summarized by one rule:

> **A Product has one Base Unit. Every other unit is a ProductUnit that defines how many Base Units it represents. Transactions are entered using the selected ProductUnit, converted to Base Quantity when posted, and inventory is always maintained in the Base Unit.**

Examples:

```text
UTP Cable
Base: meter
1 box = 305 meters
```

```text
Sugar
Base: kg
1 sack = 50 kg
```

```text
Rice
Base: kg
1 sack = 25 kg
```

```text
Engine Oil
Base: liter
1 box = 12 liters
```

```text
Brake Pad
Base: piece
1 box = 4 pieces
```

This gives Sales, Purchases, Repairs, Transfers, and Inventory one consistent mechanism for handling different selling and purchasing units.
