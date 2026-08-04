require "rails_helper"

RSpec.describe "Payments & Inventory", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:customer) { create(:customer, business: business) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "Payments" do
    it "renders the new payment form and records a payment" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-PAY", total_cents: 2000, status: :confirmed)
      get new_sales_order_payment_path(so)
      expect(response).to have_http_status(:ok)

      post sales_order_payments_path(so), params: { payment: { payment_method: "bank_transfer", amount: "20.00" } }
      expect(response).to redirect_to(sales_order_path(so))
    end

    it "re-renders new on an invalid payment" do
      so = create(:sales_order, business: business, store_location: store, customer: customer, number: "SO-PAY2", total_cents: 2000, status: :confirmed)
      post sales_order_payments_path(so), params: { payment: { payment_method: "", amount: "0" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "InventoryItems" do
    it "indexes and shows" do
      product = create(:product, business: business)
      variant = create(:product_variant, business: business, product: product)
      stock = create(:stock, business: business, store_location: store, product_variant: variant)
      item = create(:inventory_item, business: business, stock: stock, product_variant: variant)

      get inventory_items_path
      expect(response).to have_http_status(:ok)

      get inventory_item_path(item)
      expect(response).to have_http_status(:ok)
    end

    it "updates a unit status" do
      product = create(:product, business: business)
      variant = create(:product_variant, business: business, product: product)
      stock = create(:stock, business: business, store_location: store, product_variant: variant)
      item = create(:inventory_item, business: business, stock: stock, product_variant: variant, status: :available)

      post update_status_inventory_item_path(item), params: { inventory_item: { status: "sold" } }
      expect(response).to redirect_to(inventory_item_path(item))
      expect(item.reload.status.to_s).to eq("sold")
    end
  end
end
