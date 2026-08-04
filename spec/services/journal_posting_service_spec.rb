require "rails_helper"

RSpec.describe JournalPostingService do
  let(:business) { create(:business) }
  let(:ledger) { AccountingMapper.ledger_for(business) }
  let(:cash) { AccountingMapper.account(ledger, :cash) }
  let(:ar) { AccountingMapper.account(ledger, :accounts_receivable) }

  it "posts a balanced entry" do
    entry = JournalPostingService.post!(
      ledger: ledger,
      description: "Test",
      lines: [
        { account: cash, debit_cents: 1000 },
        { account: ar, credit_cents: 1000 },
      ]
    )
    expect(entry).to be_persisted
    expect(entry.status.to_s).to eq("posted")
    expect(entry.entry_number).to start_with("JE-")
  end

  it "raises on unbalanced lines" do
    expect {
      JournalPostingService.post!(
        ledger: ledger, description: "x",
        lines: [{ account: cash, debit_cents: 100 }, { account: ar, credit_cents: 50 }]
      )
    }.to raise_error(JournalPostingService::UnbalancedError)
  end

  it "raises when no lines" do
    expect {
      JournalPostingService.post!(ledger: ledger, description: "x", lines: [])
    }.to raise_error(JournalPostingService::UnbalancedError)
  end

  it "generates monotonically increasing entry numbers" do
    a = JournalPostingService.post!(ledger: ledger, description: "a",
      lines: [{ account: cash, debit_cents: 1 }, { account: ar, credit_cents: 1 }])
    b = JournalPostingService.post!(ledger: ledger, description: "b",
      lines: [{ account: cash, debit_cents: 1 }, { account: ar, credit_cents: 1 }])
    expect(a.entry_number).not_to eq(b.entry_number)
    expect(b.entry_number > a.entry_number).to be true
  end
end

RSpec.describe NumberGenerator do
  it "generates a unique prefix-numbered id" do
    PurchaseOrder.delete_all
    n1 = NumberGenerator.generate("PO-", PurchaseOrder)
    create(:purchase_order, number: n1)
    n2 = NumberGenerator.generate("PO-", PurchaseOrder)
    expect(n1).to start_with("PO-")
    expect(n2).to start_with("PO-")
    expect(n1).not_to eq(n2)
  end
end
