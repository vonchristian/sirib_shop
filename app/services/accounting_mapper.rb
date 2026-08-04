# Maps operational events to the business's chart of accounts by account code.
# A sensible default chart is created lazily so operational flows keep working.
class AccountingMapper
  CODES = {
    cash: "1100",
    accounts_receivable: "1200",
    inventory: "1300",
    accounts_payable: "2100",
    phone_sales: "4100",
    repair_revenue: "4200",
    other_revenue: "4900",
    cogs: "5100",
    purchase_discounts: "5900"
  }.freeze

  def self.ledger_for(business)
    business.ledgers.active.first || create_default_ledger!(business)
  end

  def self.account(ledger, key)
    code = CODES.fetch(key.to_sym)
    ledger.accounts.find_by(code: code) ||
      raise(KeyError, "account #{key} (#{code}) not found in chart of accounts")
  end

  def self.create_default_ledger!(business)
    Ledger.transaction do
      ledger = Ledger.create!(business: business, name: "General Ledger", code: "GL")

      [["1000", "Assets", :asset, :debit],
       ["1100", "Cash", :asset, :debit],
       ["1200", "Accounts Receivable", :asset, :debit],
       ["1300", "Inventory", :asset, :debit],
       ["2000", "Liabilities", :liability, :credit],
       ["2100", "Accounts Payable", :liability, :credit],
       ["3000", "Equity", :equity, :credit],
       ["4000", "Revenue", :revenue, :credit],
       ["4100", "Phone Sales", :revenue, :credit],
       ["4200", "Repair Revenue", :revenue, :credit],
       ["4900", "Other Revenue", :revenue, :credit],
       ["5000", "Cost of Goods Sold", :expense, :debit],
       ["5100", "Product COGS", :expense, :debit],
       ["5900", "Purchase Discounts", :expense, :credit]].each do |code, name, type, balance|
        ledger.accounts.create!(code: code, name: name, account_type: type, normal_balance: balance)
      end

      ledger
    end
  end
end
