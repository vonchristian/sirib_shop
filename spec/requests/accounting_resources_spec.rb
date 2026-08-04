require "rails_helper"

RSpec.describe "Accounting resources", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "Ledgers" do
    it "indexes, creates, and shows" do
      get ledgers_path
      expect(response).to have_http_status(:ok)

      post ledgers_path, params: { ledger: { name: "Branch ledger", code: "BL-#{rand(9999)}", status: "active" } }
      expect(response).to redirect_to(ledger_path(Ledger.last))

      get ledger_path(Ledger.last)
      expect(response).to have_http_status(:ok)
    end

    it "renders new and rejects invalid create" do
      get new_ledger_path
      expect(response).to have_http_status(:ok)

      post ledgers_path, params: { ledger: { name: "", code: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Accounts" do
    it "indexes, creates, and shows" do
      ledger = create(:ledger, business: business, status: :active)
      get ledger_accounts_path(ledger)
      expect(response).to have_http_status(:ok)

      post ledger_accounts_path(ledger), params: { account: { code: "9#{rand(999)}", name: "Test Account", account_type: "expense", normal_balance: "debit", status: "active" } }
      expect(response).to redirect_to(ledger_account_path(ledger, Account.last))

      get ledger_account_path(ledger, Account.last)
      expect(response).to have_http_status(:ok)
    end

    it "renders new and edits an account" do
      ledger = create(:ledger, business: business, status: :active)
      account = create(:account, ledger: ledger, code: "9111", name: "Wages", account_type: :expense)
      get new_ledger_account_path(ledger)
      expect(response).to have_http_status(:ok)

      get edit_ledger_account_path(ledger, account)
      expect(response).to have_http_status(:ok)

      patch ledger_account_path(ledger, account), params: { account: { name: "Salaries" } }
      expect(response).to redirect_to(ledger_account_path(ledger, account.reload))

      patch ledger_account_path(ledger, account), params: { account: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "JournalEntries" do
    it "indexes and shows" do
      ledger = AccountingMapper.ledger_for(business)
      entry = create(:journal_entry, ledger: ledger)
      get journal_entries_path
      expect(response).to have_http_status(:ok)

      get journal_entry_path(entry)
      expect(response).to have_http_status(:ok)

      get new_journal_entry_path
      expect(response).to have_http_status(:ok)
    end

    it "creates and posts a balanced journal entry" do
      ledger = AccountingMapper.ledger_for(business)
      cash = AccountingMapper.account(ledger, :cash)
      ar = AccountingMapper.account(ledger, :accounts_receivable)
      post journal_entries_path, params: {
        journal_entry: {
          ledger_id: ledger.id,
          description: "Manual entry",
          lines: [
            { account_id: cash.id, debit: "5.00", credit: "0", description: "debit" },
            { account_id: ar.id, debit: "0", credit: "5.00", description: "credit" },
          ]
        }
      }
      expect(response).to redirect_to(journal_entry_path(JournalEntry.last))
      expect(JournalEntry.last.status.to_s).to eq("posted")
    end
  end
end
