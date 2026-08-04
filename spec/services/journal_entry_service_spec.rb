require "rails_helper"

RSpec.describe JournalEntryService do
  let(:business) { create(:business) }
  let(:ledger) { AccountingMapper.ledger_for(business) }
  let(:cash) { AccountingMapper.account(ledger, :cash) }
  let(:ar) { AccountingMapper.account(ledger, :accounts_receivable) }

  describe ".create_entry!" do
    it "creates a posted, balanced entry" do
      result = JournalEntryService.create_entry!(
        ledger: ledger, description: "Manual", occurred_at: Time.current,
        lines: [{ account: cash, debit_cents: 500 }, { account: ar, credit_cents: 500 }]
      )
      expect(result.ok).to be true
      expect(result.entry.status.to_s).to eq("posted")
      expect(result.entry.journal_lines.size).to eq(2)
    end

    it "rejects unbalanced lines" do
      result = JournalEntryService.create_entry!(
        ledger: ledger, description: "bad", occurred_at: Time.current,
        lines: [{ account: cash, debit_cents: 100 }, { account: ar, credit_cents: 50 }]
      )
      expect(result.ok).to be false
      expect(result.errors).to include("debits must equal credits")
    end

    it "rejects empty lines" do
      result = JournalEntryService.create_entry!(
        ledger: ledger, description: "empty", occurred_at: Time.current, lines: []
      )
      expect(result.ok).to be false
      expect(result.errors).to include("journal entry has no lines")
    end
  end

  describe ".reverse!" do
    it "creates a mirror reversal entry" do
      entry = JournalPostingService.post!(
        ledger: ledger, description: "Sale",
        lines: [{ account: cash, debit_cents: 1000 }, { account: ar, credit_cents: 1000 }]
      )
      result = JournalEntryService.reverse!(entry)
      expect(result.ok).to be true
      expect(entry.reload.status.to_s).to eq("reversed")
      expect(result.entry.journal_lines.sum(:debit_cents)).to eq(1000)
      expect(result.entry.description).to start_with("Reversal of")
    end

    it "refuses to reverse a draft entry" do
      draft = create(:journal_entry, ledger: ledger)
      result = JournalEntryService.reverse!(draft)
      expect(result.ok).to be false
      expect(result.errors).to include("only posted entries can be reversed")
    end
  end
end
