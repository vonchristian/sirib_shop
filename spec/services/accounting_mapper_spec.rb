require "rails_helper"

RSpec.describe AccountingMapper do
  let(:business) { create(:business) }

  it "creates a default ledger with the standard chart of accounts when missing" do
    ledger = AccountingMapper.ledger_for(business)
    expect(ledger).to be_persisted
    expect(ledger.code).to eq("GL")
    expect(ledger.accounts.where(code: AccountingMapper::CODES.values)).to exist
  end

  it "returns the existing active ledger when present" do
    existing = create(:ledger, business: business, status: :active)
    Current.user = create(:user, business: business)
    expect(AccountingMapper.ledger_for(business)).to eq(existing)
  end

  it "resolves account keys to chart-of-account codes" do
    ledger = AccountingMapper.ledger_for(business)
    expect(AccountingMapper.account(ledger, :cash).code).to eq("1100")
    expect(AccountingMapper.account(ledger, :cogs).code).to eq("5100")
  end

  it "raises KeyError for an unknown mapping" do
    ledger = AccountingMapper.ledger_for(business)
    expect { AccountingMapper.account(ledger, :bogus) }.to raise_error(KeyError)
  end
end
