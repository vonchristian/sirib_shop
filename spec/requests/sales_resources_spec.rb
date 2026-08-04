require "rails_helper"

RSpec.describe "Sales orders & returns", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:customer) { create(:customer, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "SalesOrders" do
    it "indexes and shows" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-T-1", total_cents: 1000)
      get sales_orders_path
      expect(response).to have_http_status(:ok)

      get sales_order_path(so)
      expect(response).to have_http_status(:ok)
    end

    it "cancels a draft sales order" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-CANCEL", status: :draft, total_cents: 0)
      post cancel_sales_order_path(so)
      expect(so.reload.status.to_s).to eq("cancelled")
    end

    it "completes a fully paid sales order" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-COMPLETE", status: :confirmed, total_cents: 1000)
      create(:payment, business: business, sales_order: so, payment_method: "cash", amount_cents: 1000)
      post complete_sales_order_path(so)
      expect(so.reload.status.to_s).to eq("completed")
    end

    it "refuses to complete an order with an outstanding balance" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-BAL", status: :confirmed, total_cents: 1000)
      post complete_sales_order_path(so)
      expect(so.reload.status.to_s).to eq("confirmed")
    end

    it "posts a sales order" do
      product = create(:product, business: business)
      variant = create(:product_variant, business: business, product: product)
      create(:stock, business: business, store_location: store, product_variant: variant, quantity: 10)
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-POST", total_cents: 1000, status: :confirmed)
      create(:sales_order_line, sales_order: so, product_variant: variant, quantity: 1, unit_price_cents: 1000, total_cents: 1000)
      post post_sales_order_path(so)
      expect(so.reload.status.to_s).to eq("fulfilled")
    end
  end

  describe "SalesReturns" do
    it "indexes and shows" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-RX", total_cents: 1000)
      sr = create(:sales_return, business: business, sales_order: so, store_location: store)
      get sales_returns_path
      expect(response).to have_http_status(:ok)

      get sales_return_path(sr)
      expect(response).to have_http_status(:ok)
    end

    it "renders new" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-RX2", total_cents: 1000)
      get new_sales_return_path(sales_order_id: so.id, store_location_id: store.id)
      expect(response).to have_http_status(:ok)
    end

    it "creates a sales return" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-RX3", total_cents: 1000)
      post sales_returns_path, params: {
        sales_return: {
          sales_order_id: so.id,
          store_location_id: store.id,
          reason: "Defective",
          lines: [{ product_variant_id: variant.id, quantity: "1", unit_price: "50.00" }]
        }
      }
      expect(response).to redirect_to(sales_return_path(SalesReturn.last))
    end

    it "completes a sales return" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-RX4", total_cents: 1000)
      sr = create(:sales_return, business: business, sales_order: so, store_location: store)
      create(:sales_return_line, sales_return: sr, product_variant: variant, quantity: 1, unit_price_cents: 5000)
      create(:stock, business: business, store_location: store, product_variant: variant, quantity: 0)
      post complete_sales_return_path(sr)
      expect(sr.reload.status.to_s).to eq("completed")
    end
  end
end
