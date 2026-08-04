# PRD — Daily Cashier Operations MVP

## 1. Objective

Provide a simple daily workflow for Sales Clerks/Cashiers to manage their assigned Cash Account and produce a complete End-of-Day report.

The module covers:

* Opening cash
* Cash receipts
* Check receipts
* Cash disbursements
* Manager → Cashier transfers
* Cashier → Manager transfers
* SalesOrders paid during the day
* WorkOrders paid during the day
* Physical cash counting
* Cash over/short
* EOD reporting

### Core principle

> **Sirib calculates expected physical cash from actual cash transactions. Checks are tracked separately and do not increase the cashier's physical Cash Account until deposited.**

---

# 2. Cashier Account

Each Sales Clerk/Cashier is assigned a Cash Account for a Store Location.

```text
User
 ↓
Store Location
 ↓
Cash Account
```

Example:

```text
Maria Santos
Sales Clerk

Main Branch

Cash Account:
Cashier 01
```

The cashier operates the Cash Account assigned to them for their current Store Location.

---

# 3. Daily Cashier Session

The cashier begins the day by opening a session.

```text
Cashier
 ↓
Open Session
 ↓
Enter Opening Cash
 ↓
Start Day
```

Example:

```text
OPEN CASHIER SESSION

Cash Account:
Cashier 01

Opening Cash:
₱5,000

[ Start Day ]
```

---

# 4. Cashier Session

```text
CashierSession
--------------
id

user_id
store_location_id
cash_account_id

business_date

opening_amount
closing_amount

status

opened_at
closed_at
```

Status:

```text
Open
Closed
```

Only one open session should exist for a cashier/Cash Account at a time.

---

# 5. Cash Receipts

Cash receipts increase the cashier's physical Cash Account.

Sources include:

### Cash SalesOrder Payment

```text
POS
 ↓
SalesOrder
 ↓
Cash Payment
 ↓
Cashier Cash Account
```

### Cash WorkOrder Payment

```text
WorkOrder
 ↓
RepairInvoice
 ↓
Cash Payment
 ↓
Cashier Cash Account
```

### Manager Transfer

```text
Manager Cash Account
 ↓
Cashier Cash Account
```

Manager transfers are shown separately from customer receipts.

---

# 6. Check Receipts

A check is a customer payment, but **it is not physical cash**.

When the customer pays by check:

```text
Invoice
 ↓
Check Payment
 ↓
Undeposited Checks
```

The cashier's physical Cash Account does not increase.

Accounting:

```text
Dr Undeposited Checks
Cr Accounts Receivable
```

The customer's invoice balance is reduced.

---

# 7. Undeposited Checks

Use an asset account:

```text
Undeposited Checks
```

This represents physical checks held by the business but not yet deposited.

Example:

```text
Customer Check:
₱50,000

Cash Account:
No increase

Undeposited Checks:
+₱50,000
```

---

# 8. Depositing a Check

When the check is deposited:

```text
Undeposited Checks
 ↓
Bank Account
```

Accounting:

```text
Dr Bank
Cr Undeposited Checks
```

The physical Cash Account is still not affected unless the business actually deposits into that specific cash account.

The Bank Account increases.

---

# 9. Bounced Check

If a check is returned/bounced:

```text
Dr Accounts Receivable
Cr Undeposited Checks
```

The customer's outstanding balance is restored.

The payment should be marked:

```text
Bounced
```

---

# 10. Check Status

Check payments support:

```text
Received
Deposited
Cleared
Bounced
Cancelled
```

Initial status:

```text
Received
```

For MVP, the cashier primarily records the check as **Received**.

Treasury/Manager handles subsequent deposit/status updates.

---

# 11. Check Information

Check payments should use explicit fields:

```text
check_number
check_bank
check_date
check_status
```

Do not use JSONB metadata for check information.

---

# 12. Cash Disbursements

Cash disbursements decrease the cashier's physical Cash Account.

Example:

```text
Cashier Cash
 ↓
Approved Cash Disbursement
```

Each disbursement must have a source/reference.

The cashier operations module does not become a general expense-entry system.

Cash disbursements follow the existing Voucher workflow.

---

# 13. Manager → Cashier Transfer

The Manager can transfer cash to the cashier.

```text
Manager Cash
 ↓
Cashier 01
```

Example:

```text
TRANSFER CASH

From:
Manager Cash

To:
Cashier 01

Amount:
₱10,000

Reason:
Additional operating cash

[ Preview ]
[ Confirm ]
```

Accounting:

```text
Dr Cashier Cash
Cr Manager Cash
```

The cashier's expected physical cash increases by ₱10,000.

---

# 14. Cashier → Manager Transfer

The cashier can transfer cash to the Manager.

```text
Cashier 01
 ↓
Manager Cash
```

Example:

```text
TRANSFER CASH

From:
Cashier 01

To:
Manager Cash

Amount:
₱20,000

Reason:
Cash turnover

[ Preview ]
[ Confirm ]
```

Accounting:

```text
Dr Manager Cash
Cr Cashier Cash
```

The cashier's expected physical cash decreases by ₱20,000.

---

# 15. Transfer Rules

Every transfer contains:

```text
from_cash_account
to_cash_account
amount
date/time
reason
created_by
```

Rules:

* Amount must be greater than zero.
* Source and destination must differ.
* Source account must have sufficient available cash.
* Transfer requires Preview → Confirm.
* Transfer creates the appropriate Voucher.
* Accounting entry is generated from Voucher details.

---

# 16. Cashier Dashboard

During the day:

```text
TODAY

Cashier 01
Main Branch

Opening Cash
₱5,000

Cash Receipts
₱45,000

Cash Disbursements
₱5,000

Received From Manager
₱10,000

Transferred To Manager
₱20,000

Expected Cash
₱35,000

Checks Received
₱65,000

[ Transactions ]
[ Transfer Cash ]
[ End Day ]
```

Checks are displayed separately and are not included in Expected Cash.

---

# 17. Expected Physical Cash

Expected cash is calculated as:

```text
Opening Cash
+ Cash Receipts
+ Manager Transfers In
- Cash Disbursements
- Manager Transfers Out
= Expected Physical Cash
```

Check receipts are excluded.

Example:

```text
Opening Cash                 ₱5,000
Cash Receipts               ₱45,000
Manager Transfer In         ₱10,000
Cash Disbursements          (₱5,000)
Manager Transfer Out       (₱20,000)
                            --------
Expected Cash               ₱35,000
```

---

# 18. SalesOrder Payments

Every customer payment is linked to an Invoice.

The Invoice identifies its source:

```text
Payment
 ↓
Invoice
 ↓
SalesOrder
```

Example:

```text
Cash Receipt

SalesOrder:
SO-2026-001

Invoice:
INV-2026-001

Customer:
ABC Trading

Amount:
₱25,000
```

The EOD report must be able to identify all SalesOrders paid during the day.

---

# 19. WorkOrder Payments

Repair payments follow the same structure:

```text
Payment
 ↓
Invoice
 ↓
WorkOrder
```

Example:

```text
Cash Receipt

WorkOrder:
WO-2026-0042

Invoice:
INV-2026-0042

Customer:
Juan Dela Cruz

Amount:
₱8,500
```

The EOD report must identify all WorkOrders paid during the day.

---

# 20. Payment Methods

MVP supports:

```text
Cash
Check
```

No external payment gateway integration.

---

# 21. End-of-Day Workflow

At the end of the day:

```text
Cashier
 ↓
[ End Day ]
 ↓
Review Transactions
 ↓
Count Physical Cash
 ↓
Enter Actual Cash
 ↓
Calculate Difference
 ↓
Review EOD Report
 ↓
Confirm
 ↓
Close Session
```

---

# 22. EOD Report

The EOD report is the primary management report for the cashier session.

It must include:

1. Session information
2. Cash receipts breakdown
3. Cash disbursements breakdown
4. SalesOrders paid
5. WorkOrders paid
6. Check receipts
7. Manager transfers
8. Cash summary
9. Physical cash count
10. Cash over/short

---

# 23. EOD Report — Header

```text
DAILY CASHIER REPORT

Business:
ABC Computer & Motorcycle Services

Store:
Main Branch

Cashier:
Maria Santos

Cash Account:
Cashier 01

Business Date:
August 3, 2026

Session:
CS-2026-0803-001
```

---

# 24. EOD Report — Cash Receipts

Show the detailed cash receipts.

```text
CASH RECEIPTS

SalesOrder Payments
--------------------------------
SO-2026-001    ABC Trading       ₱25,000
SO-2026-002    XYZ Corp           ₱8,500

Total SalesOrder Receipts:
₱33,500


WorkOrder Payments
--------------------------------
WO-2026-001    Juan Dela Cruz     ₱5,000
WO-2026-002    Pedro Santos       ₱7,500

Total WorkOrder Receipts:
₱12,500


Other Cash Receipts
--------------------------------
Other                           ₱0

TOTAL CASH RECEIPTS:
₱46,000
```

---

# 25. EOD Report — SalesOrders Paid

Dedicated breakdown:

```text
SALES ORDERS PAID

Sales Order    Customer       Invoice       Amount
---------------------------------------------------
SO-2026-001    ABC Trading     INV-001       ₱25,000
SO-2026-002    XYZ Corp        INV-002        ₱8,500

TOTAL:
₱33,500
```

If an order receives multiple payments during the day, show each payment in the detailed report while allowing the summary to group by SalesOrder.

---

# 26. EOD Report — WorkOrders Paid

Dedicated breakdown:

```text
WORK ORDERS PAID

Work Order     Customer        Invoice       Amount
----------------------------------------------------
WO-2026-001    Juan Dela Cruz   INV-003       ₱5,000
WO-2026-002    Pedro Santos     INV-004       ₱7,500

TOTAL:
₱12,500
```

---

# 27. EOD Report — Cash Disbursements

```text
CASH DISBURSEMENTS

Reference       Description             Amount
------------------------------------------------
CDV-001         Office supplies          ₱2,000
CDV-002         Store expense             ₱3,000

TOTAL:
₱5,000
```

Each disbursement links to its Voucher/transaction reference.

---

# 28. EOD Report — Check Receipts

Checks are shown separately.

```text
CHECK RECEIPTS

Source        Customer        Check No.    Amount
--------------------------------------------------
SO-2026-010   City Government  12345       ₱50,000
WO-2026-011   ABC Corp         12346       ₱15,000

TOTAL CHECKS RECEIVED:
₱65,000
```

These amounts:

* Reduce customer receivables.
* Increase Undeposited Checks.
* Do not increase Cashier Cash.
* Do not increase Expected Physical Cash.

---

# 29. EOD Report — Manager Transfers

```text
CASH TRANSFERS

Received From Manager:
₱10,000

Transferred To Manager:
₱20,000

Net Transfer:
(₱10,000)
```

Transfers are not included in customer receipt totals.

---

# 30. EOD Report — Cash Summary

```text
CASH SUMMARY

Opening Cash                       ₱5,000

Cash Receipts                     ₱46,000
Cash Disbursements                (₱5,000)

Received From Manager             ₱10,000
Transferred To Manager           (₱20,000)

------------------------------------------
EXPECTED PHYSICAL CASH             ₱36,000
```

---

# 31. Physical Cash Count

The cashier enters the actual physical cash.

```text
PHYSICAL CASH COUNT

Expected Cash:
₱36,000

Actual Cash:
₱36,000

Difference:
₱0
```

---

# 32. Cash Short

If:

```text
Expected:
₱36,000

Actual:
₱35,500
```

show:

```text
Cash Short:
₱500
```

The cashier must provide an explanation.

---

# 33. Cash Over

If:

```text
Expected:
₱36,000

Actual:
₱36,200
```

show:

```text
Cash Over:
₱200
```

The cashier must provide an explanation.

---

# 34. Final EOD Summary

```text
DAILY SUMMARY

Cash Receipts:
₱46,000

Cash Disbursements:
₱5,000

SalesOrders Paid:
₱33,500

WorkOrders Paid:
₱12,500

Checks Received:
₱65,000

Manager Transfers In:
₱10,000

Manager Transfers Out:
₱20,000

Expected Physical Cash:
₱36,000

Actual Physical Cash:
₱36,000

Cash Over/Short:
₱0
```

---

# 35. Accounting Flow

All cash-affecting transactions follow:

```text
Transaction
 ↓
Create Voucher
 ↓
Preview
 ↓
Confirm / Cancel
 ↓
Accounting Entry
```

### Customer Cash Payment

```text
Dr Cashier Cash
Cr Accounts Receivable
```

### Customer Check Payment

```text
Dr Undeposited Checks
Cr Accounts Receivable
```

### Check Deposit

```text
Dr Bank
Cr Undeposited Checks
```

### Manager → Cashier

```text
Dr Cashier Cash
Cr Manager Cash
```

### Cashier → Manager

```text
Dr Manager Cash
Cr Cashier Cash
```

The exact Cash/Bank account is determined by the accounts configured for the transaction.

---

# 36. Important Accounting Rule

The system must distinguish:

```text
Customer Payment
```

from:

```text
Physical Cash Receipt
```

Therefore:

```text
Cash Payment
→ Cash Account increases

Check Payment
→ Undeposited Checks increases

Check Deposit
→ Bank Account increases
```

This ensures the cashier's physical cash balance remains accurate.

---

# 37. Permissions

## Sales Clerk / Cashier

Can:

* Open their session
* View their transactions
* Process POS cash sales
* Receive customer cash payments
* Receive customer check payments
* Receive manager transfers
* Transfer cash to manager
* View their EOD report
* Close their session

Cannot:

* Modify completed transactions
* Transfer from another cashier
* Close another cashier's session
* Modify accounting entries

## Manager

Can:

* Open their own session
* Transfer cash to/from cashiers
* View cashier sessions
* View EOD reports
* Review cash differences
* Receive cashier turnovers
* Perform cashier operations when acting as cashier

---

# 38. Multi-Location

The cashier operates under the user's Current Store Location.

```text
User
 ↓
Current Store Location
 ↓
Assigned Cash Account
 ↓
Cashier Session
```

Switching the Current Store Location changes the active operational context.

The system uses the Cash Account assigned to the user for that location.

---

# 39. Hotwire / Stimulus UX

Use Hotwire and Stimulus for:

* Live expected-cash calculation
* Transfer amount validation
* EOD cash-difference calculation
* Payment confirmation
* EOD report preview
* Printing

The cashier should not need to reload the page during normal operations.

---

# 40. Data Relationships

```text
User
 │
 └── CashierSession
       │
       └── Cash Account
```

Customer collections:

```text
CustomerPayment
       │
       ▼
    Invoice
     /    \
    ▼      ▼
SalesOrder WorkOrder
```

Check handling:

```text
CustomerPayment
       │
     Check
       │
       ▼
Undeposited Checks
       │
   Deposit
       │
       ▼
     Bank
```

---

# 41. MVP Rules

1. Each cashier operates an assigned Cash Account.
2. A cashier opens one daily CashierSession.
3. Opening cash is recorded when the session starts.
4. Cash SalesOrder payments increase physical Cash.
5. Cash WorkOrder payments increase physical Cash.
6. Check payments do not increase physical Cash.
7. Check payments increase Undeposited Checks.
8. Depositing a check transfers the balance from Undeposited Checks to Bank.
9. Bounced checks restore the customer's Accounts Receivable.
10. Manager → Cashier transfers increase expected cash.
11. Cashier → Manager transfers decrease expected cash.
12. Cash disbursements decrease expected cash.
13. All cash transfers use Preview → Confirm.
14. Expected physical cash is calculated automatically.
15. EOD requires an actual physical cash count.
16. Cash over/short is calculated automatically.
17. Cash differences require an explanation.
18. EOD reports show detailed cash receipts.
19. EOD reports show detailed cash disbursements.
20. EOD reports separately list SalesOrders paid during the day.
21. EOD reports separately list WorkOrders paid during the day.
22. EOD reports separately list checks received.
23. EOD reports separately list manager transfers.
24. Check receipts are never included in physical cash.
25. One customer payment belongs to exactly one Invoice.
26. The Invoice identifies whether the payment relates to a SalesOrder or WorkOrder.
27. Accounting entries are generated through the Voucher workflow.
28. Cashier Operations does not duplicate POS, Invoice, or Accounting functionality.
29. A closed CashierSession cannot be normally edited by the cashier.
30. Managers can review cashier sessions and EOD reports.

---

# 42. Final Daily Workflow

```text
START DAY
    │
    ▼
Opening Cash
    │
    ▼
┌──────────────────────────────┐
│        CASHIER OPERATIONS    │
│                              │
│  Cash Sales                  │
│  Cash WorkOrder Payments     │
│  Check Payments              │
│  Manager Transfers In        │
│  Manager Transfers Out       │
│  Cash Disbursements          │
└──────────────────────────────┘
    │
    ▼
END DAY
    │
    ├── Review Cash Receipts
    ├── Review Cash Disbursements
    ├── Review SalesOrders Paid
    ├── Review WorkOrders Paid
    ├── Review Checks Received
    └── Review Transfers
    │
    ▼
Count Physical Cash
    │
    ▼
Expected vs Actual
    │
    ▼
Cash Over / Short
    │
    ▼
Confirm EOD
    │
    ▼
Close Cashier Session
```

## Final Product Principle

The cashier should be able to answer at any time:

> **"How much physical cash should be in my drawer right now?"**

And management should be able to answer at EOD:

> **"What did this cashier collect, what did they disburse, which SalesOrders and WorkOrders were paid, what checks were received, what cash was transferred, and does the physical cash match the system?"**

That is the complete MVP scope for daily cashier operations.
