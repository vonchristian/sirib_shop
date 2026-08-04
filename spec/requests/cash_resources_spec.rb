require "rails_helper"

RSpec.describe "Cash & register resources", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:register) { create(:cash_register, business: business, store_location: store) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "CashRegisters" do
    include_examples "a standard crud controller", resource: :cash_register, record_class: CashRegister,
      factory: :cash_register,
      record: -> { create(:cash_register, business: business, store_location: store) },
      valid_params: -> { { name: "Reg 2", code: "REG-#{rand(9999)}", store_location_id: store.id, status: "active" } },
      invalid_params: -> { { name: "", status: "active" } }
  end

  describe "CashSessions" do
    it "indexes and shows new" do
      get cash_sessions_path
      expect(response).to have_http_status(:ok)

      get new_cash_session_path
      expect(response).to have_http_status(:ok)
    end

    it "creates an open session" do
      post cash_sessions_path, params: { cash_session: { cash_register_id: register.id, opening_amount: "100.00" } }
      expect(response).to redirect_to(cash_session_path(CashSession.last))
    end

    it "closes an open session" do
      session = create(:cash_session, cash_register: register, user: user, opening_amount_cents: 100_00)
      post close_cash_session_path(session), params: { actual_closing_amount: "100.00" }
      expect(session.reload.status.to_s).to eq("closed")
    end
  end
end
