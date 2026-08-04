require "rails_helper"

RSpec.describe Account, type: :model do
  let(:ledger) { create(:ledger) }

  it "belongs to a ledger and exposes enums" do
    account = create(:account, ledger: ledger, account_type: :asset, normal_balance: :debit)
    expect(account.account_type.to_s).to eq("asset")
    expect(account.normal_balance.to_s).to eq("debit")
  end

  it "rejects parent from a different ledger" do
    other = create(:ledger)
    parent = create(:account, ledger: other)
    child = build(:account, ledger: ledger, parent: parent)
    expect(child).not_to be_valid
  end
end

RSpec.describe JournalLine, type: :model do
  let(:entry) { create(:journal_entry) }
  let(:account) { create(:account, ledger: entry.ledger) }

  it "requires debit or credit" do
    line = JournalLine.new(journal_entry: entry, account: account)
    expect(line).not_to be_valid
  end

  it "rejects both debit and credit" do
    line = JournalLine.new(journal_entry: entry, account: account, debit_cents: 100, credit_cents: 50)
    expect(line).not_to be_valid
  end

  it "accepts a debit-only line" do
    line = JournalLine.new(journal_entry: entry, account: account, debit_cents: 100)
    expect(line).to be_valid
  end
end

RSpec.describe CashMovement, type: :model do
  let(:session) { create(:cash_session) }

  it "requires occurred_at" do
    m = CashMovement.new(cash_session: session, amount_cents: 100, movement_type: :cash_in, occurred_at: nil)
    expect(m).not_to be_valid
  end

  it "allows a polymorphic reference" do
    payment = create(:payment, sales_order: create(:sales_order))
    m = CashMovement.new(cash_session: session, amount_cents: 100, movement_type: :sale, occurred_at: Time.current, reference: payment)
    expect(m).to be_valid
  end
end

RSpec.describe ServiceAssetField, type: :model do
  let(:category) { create(:service_asset_category) }

  it "requires name and label" do
    f = build(:service_asset_field, service_asset_category: category, name: nil, label: nil)
    expect(f).not_to be_valid
  end

  it "enforces name uniqueness per category" do
    create(:service_asset_field, service_asset_category: category, name: "imei_1", label: "IMEI 1")
    dup = build(:service_asset_field, service_asset_category: category, name: "imei_1", label: "IMEI 1")
    expect(dup).not_to be_valid
  end
end

RSpec.describe ServiceAssetValue, type: :model do
  let(:customer) { create(:customer) }
  let(:category) { customer.business.service_asset_categories.create!(name: "Phones", active: true) }
  let(:asset) { create(:service_asset, business: customer.business, customer: customer, service_asset_category: category) }
  let(:text_field) { create(:service_asset_field, service_asset_category: category, name: "brand", label: "Brand", data_type: :text, required: true) }

  it "stores text values" do
    value = build(:service_asset_value, service_asset: asset, service_asset_field: text_field)
    value.value = "Apple"
    expect(value).to be_valid
    expect(value.text_value).to eq("Apple")
    expect(value.value).to eq("Apple")
  end

  it "rejects blank required text values" do
    value = build(:service_asset_value, service_asset: asset, service_asset_field: text_field, text_value: "")
    expect(value).not_to be_valid
  end

  it "rejects a field from a different category" do
    other_cat = create(:service_asset_category)
    other_field = create(:service_asset_field, service_asset_category: other_cat)
    value = build(:service_asset_value, service_asset: asset, service_asset_field: other_field)
    expect(value).not_to be_valid
  end
end
