# PRD-006 --- Accounting Ledger & Journal Entries

## 1. Objective

Provide a clean double-entry accounting foundation without coupling
operational models to the accounting `Account` model.

## 2. Critical naming rule

`Account` means a **General Ledger accounting account**.

It does not mean:

-   customer account
-   user account
-   business account

Operational customer relationships use `Customer`.

## 3. Ledger

### Fields

``` text
id
business_id
name
code
status
```

A business normally starts with one General Ledger.

## 4. Account

### Fields

``` text
id
ledger_id
parent_id
code
name
account_type
normal_balance
status
```

Account types:

``` text
asset
liability
equity
revenue
expense
```

Example chart:

``` text
1000 Assets
├── 1100 Cash
├── 1200 Accounts Receivable
└── 1300 Inventory

4000 Revenue
├── 4100 Phone Sales
└── 4200 Repair Revenue

5000 Cost of Goods Sold
└── 5100 Product COGS
```

## 5. JournalEntry

### Fields

``` text
id
ledger_id
reference_type
reference_id
entry_number
description
occurred_at
posted_at
status
created_at
```

Statuses:

``` text
draft
posted
reversed
```

## 6. JournalLine

Rename the originally proposed `AmountLine` to `JournalLine`.

### Fields

``` text
id
journal_entry_id
account_id
description
debit
credit
```

Rules:

``` text
debit >= 0
credit >= 0
not both debit and credit on the same line
SUM(debits) == SUM(credits)
```

## 7. Example sale

Sale for ₱49,990:

``` text
Debit   Cash/Receivable       49,990
Credit  Phone Sales Revenue   49,990
```

COGS example:

``` text
Debit   Cost of Goods Sold    35,000
Credit  Inventory             35,000
```

## 8. Inventory/accounting separation

Operational inventory:

``` text
Stock
  ↓
LineItem
```

Accounting:

``` text
JournalEntry
  ↓
JournalLine
  ↓
Account
```

The same business event may produce both.

Example:

``` text
SalesOrder
   ├── Inventory LineItem
   └── JournalEntry
```

Do not make `Stock` directly own accounting accounts.

## 9. Posting rules

Accounting entries must be created transactionally with the operational
event when the business event is considered financially posted.

For retryable workflows:

-   posting must be idempotent
-   a business event must not create duplicate journal entries
-   posted entries are immutable
-   corrections use reversal entries

## 10. Acceptance criteria

-   Business can create a chart of accounts.
-   Journal entries require balanced debit/credit lines.
-   Unbalanced entries cannot be posted.
-   Posted entries cannot be edited.
-   Operational events can reference their accounting entries.
-   Duplicate posting is prevented.
-   Inventory and accounting remain separate bounded concepts.
