require "rails_helper"

RSpec.describe "Transfer orders & purchase returns", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:origin) { create(:store_location, business: business, is_main: true) }
  let(:destination) { create(:store_location, business: business) }
  let(:supplier) { create(:supplier, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "TransferOrders" do
    it "indexes, renders new, creates, and shows" do
      get transfer_orders_path
      expect(response).to have_http_status(:ok)

      get new_transfer_order_path
      expect(response).to have_http_status(:ok)

      post transfer_orders_path, params: {
        transfer_order: {
          origin_store_location_id: origin.id,
          destination_store_location_id: destination.id,
          lines: [{ product_variant_id: variant.id, quantity: "2" }]
        }
      }
      expect(response).to redirect_to(transfer_order_path(TransferOrder.last))

      get transfer_order_path(TransferOrder.last)
      expect(response).to have_http_status(:ok)
    end

    it "approves, ships, and receives a transfer" do
      create(:stock, business: business, store_location: origin, product_variant: variant, quantity: 10)
      t = create(:transfer_order, business: business, origin_store_location: origin, destination_store_location: destination, status: :draft)
      create(:transfer_order_line, transfer_order: t, product_variant: variant, quantity: 3)

      post approve_transfer_order_path(t)
      expect(t.reload.status.to_s).to eq("approved")

      post ship_transfer_order_path(t)
      expect(t.reload.status.to_s).to eq("shipped")

      post receive_transfer_order_path(t)
      expect(t.reload.status.to_s).to eq("received")
      expect(Stock.where(store_location: destination, product_variant: variant).first.quantity).to eq(3)
    end

    it "cancels a draft transfer" do
      t = create(:transfer_order, business: business, origin_store_location: origin, destination_store_location: destination, status: :draft)
      post cancel_transfer_order_path(t)
      expect(t.reload.status.to_s).to eq("cancelled")
    end
  end

  describe "PurchaseReturns" do
    it "indexes, renders new, creates, and shows" do
      po = create(:purchase_order, business: business, supplier: supplier, destination_store_location: origin)
      get purchase_returns_path
      expect(response).to have_http_status(:ok)

      get new_purchase_return_path
      expect(response).to have_http_status(:ok)

      post purchase_returns_path, params: {
        purchase_return: {
          purchase_order_id: po.id,
          supplier_id: supplier.id,
          store_location_id: origin.id,
          reason: "Damaged",
          lines: [{ product_variant_id: variant.id, quantity: "1", unit_cost: "50.00" }]
        }
      }
      expect(response).to redirect_to(purchase_return_path(PurchaseReturn.last))

      get purchase_return_path(PurchaseReturn.last)
      expect(response).to have_http_status(:ok)
    end

    it "completes a purchase return" do
      po = create(:purchase_order, business: business, supplier: supplier, destination_store_location: origin)
      pr = create(:purchase_return, business: business, purchase_order: po, supplier: supplier, store_location: origin)
      create(:purchase_return_line, purchase_return: pr, product_variant: variant, quantity: 1, unit_cost_cents: 5000)
      create(:stock, business: business, store_location: origin, product_variant: variant, quantity: 5)
      post complete_purchase_return_path(pr)
      expect(pr.reload.status.to_s).to eq("completed")
    end
  end
end
