| Priority | PRD                                 | Why it's needed                                                                      |
| -------- | ----------------------------------- | ------------------------------------------------------------------------------------ |
| 🔴 P0    | **Product & Inventory**             | Sales, purchases, repairs, spare parts all depend on it                              |
| 🔴 P0    | **Accounting Core**                 | Voucher → accounting entry, AR/AP, chart of accounts                                 |
| 🔴 P0    | **Payments & Receivables**          | You have invoices and partial payments; this defines the actual payment lifecycle    |
| 🔴 P0    | **Purchasing & Receiving**          | Your purchase flow needs receiving inventory, not just entering purchases            |
| 🔴 P0    | **Inventory Movements**             | Sales, purchases, transfers, spoilage, internal use and repairs all change inventory |
| 🟠 P1    | **Supplier Management**             | Needed for purchases and Accounts Payable                                            |
| 🟠 P1    | **Customer Credit Management**      | Needed to control credit sales and outstanding balances                              |
| 🟠 P1    | **Store Location / Access Control** | You already have multi-location access, but need the final permission model          |
| 🟠 P1    | **Repair Inventory Consumption**    | WorkOrders need spare parts/internal-use inventory deductions                        |
| 🟠 P1    | **Reports & Export**                | Management needs operational reports beyond cashier EOD                              |
| 🟡 P2    | **Sales Returns**                   | Needed once basic sales are working                                                  |
| 🟡 P2    | **Purchase Returns**                | Needed once purchasing is working                                                    |
| 🟡 P2    | **Inventory Transfers**             | Needed for multiple branches                                                         |
| 🟡 P2    | **Contracts / Won Bids**            | Useful for your LGU/government customers, but can stay very small                    |
