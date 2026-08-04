require "rails_helper"

RSpec.describe CashSessionService do
  let(:business) { create(:business) }
  let(:store) { create(:store_location, business: business) }
  let(:reg) { create(:cash_register, business: business, store_location: store) }
  let(:user) { create(:user, business: business) }

  before { Current.user = user }

  it "opens a session and records an opening movement" do
    result = CashSessionService.open!(cash_register: reg, user: user, opening_amount_cents: 500_00)
    expect(result.ok).to be true
    expect(result.cash_session).to be_open
    expect(result.cash_session.cash_movements.where(movement_type: :opening, amount_cents: 500_00)).to exist
  end

  it "rejects opening when the register already has an open session" do
    create(:cash_session, cash_register: reg, user: user)
    result = CashSessionService.open!(cash_register: reg, user: user)
    expect(result.ok).to be false
    expect(result.errors.first).to match(/already has an open session/)
  end

  it "adds cash in / out to an open session" do
    session = create(:cash_session, cash_register: reg, user: user)
    in_result = CashSessionService.add_cash!(session, movement_type: :cash_in, amount_cents: 200_00)
    out_result = CashSessionService.add_cash!(session, movement_type: :cash_out, amount_cents: 50_00)
    expect(in_result.ok).to be true
    expect(out_result.ok).to be true
    expect(session.cash_movements.pluck(:movement_type)).to include("cash_in", "cash_out")
  end

  it "refuses to add cash to a closed session" do
    session = create(:cash_session, cash_register: reg, user: user, status: :closed)
    result = CashSessionService.add_cash!(session, movement_type: :cash_in, amount_cents: 100)
    expect(result.ok).to be false
    expect(result.errors).to include("session is not open")
  end

  it "closes an open session and computes the difference" do
    session = create(:cash_session, cash_register: reg, user: user, opening_amount_cents: 100_00)
    CashSessionService.add_cash!(session, movement_type: :cash_in, amount_cents: 25_00)
    result = CashSessionService.close!(session, actual_closing_amount_cents: 130_00)
    expect(result.ok).to be true
    expect(result.cash_session).to be_closed
    expect(result.cash_session.expected_closing_amount_cents).to eq(125_00)
    expect(result.cash_session.difference_cents).to eq(5_00)
  end
end
