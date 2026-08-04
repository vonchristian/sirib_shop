require "rails_helper"

RSpec.describe PaymentService do
  let(:business) { create(:business) }
  let(:ledger) { AccountingMapper.ledger_for(business) }
  let(:store) { create(:store_location, business: business) }
  let(:customer) { create(:customer, business: business) }
  let(:user) { create(:user, business: business) }
  let(:variant) { create(:product_variant, business: business) }
  let(:order) do
    so = SalesOrder.new(business: business, store_location: store, customer: customer, created_by_user: user, number: "SO-1", status: :confirmed, ordered_at: Time.current)
    so.subtotal_cents = 10000
    so.total_cents = 10000
    so.save!
    so
  end

  before do
    Current.user = user
    
  end

  it "records a bank transfer payment and posts AR journal" do
    result = PaymentService.record!(order: order, payment_method: :bank_transfer, amount_cents: 10000)
    expect(result.created).to be true
    expect(result.payment.amount_cents).to eq(10000)
    expect(result.payment.payment_method.to_s).to eq("bank_transfer")
    expect(result.payment.cash_session).to be_nil
    expect(result.errors).to be_empty

    entry = JournalEntry.find_by(ledger: ledger, description: "Payment for SO-1 (bank_transfer)")
    expect(entry).to be_present
    expect(entry.status.to_s).to eq("posted")
    expect(entry.journal_lines.sum(:debit_cents)).to eq(10000)
  end

  it "records a cash payment against the active cash session at the order's location" do
    reg = create(:cash_register, business: business, store_location: store)
    session = create(:cash_session, cash_register: reg, user: user)

    result = PaymentService.record!(order: order, payment_method: :cash, amount_cents: 5000)
    expect(result.created).to be true
    expect(result.payment.cash_session).to eq(session)
    expect(session.cash_movements.where(movement_type: :sale, amount_cents: 5000)).to exist
  end

  it "completes the order when fully paid" do
    PaymentService.record!(order: order, payment_method: :bank_transfer, amount_cents: 10000)
    expect(order.reload.status.to_s).to eq("completed")
  end

  it "returns not-created when chart of accounts is missing the required code" do
    empty_ledger = create(:ledger, business: business, status: :active)
    Current.user = user
    # Force ledger_for to return the empty ledger (suppress default creation by having an active ledger)
    allow(AccountingMapper).to receive(:ledger_for).and_return(empty_ledger)
    result = PaymentService.record!(order: order, payment_method: :bank_transfer, amount_cents: 10000)
    expect(result.created).to be false
    expect(result.errors.first).to match(/not found/)
  end
end
