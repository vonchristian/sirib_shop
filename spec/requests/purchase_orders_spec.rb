require "rails_helper"

RSpec.describe "Purchase orders", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:supplier) { create(:supplier, business: business) }
  let(:variant) { create(:product_variant, business: business) }

  before { sign_in(user) }

  it "indexes, shows, and renders new" do
    po = create(:purchase_order, business: business, supplier: supplier, destination_store_location: store)
    get purchase_orders_path
    expect(response).to have_http_status(:ok)
    get purchase_order_path(po)
    expect(response).to have_http_status(:ok)
    get new_purchase_order_path
    expect(response).to have_http_status(:ok)
    get receive_purchase_order_path(po)
    expect(response).to have_http_status(:ok)
  end

  it "creates, submits, approves, and receives a purchase order" do
    post purchase_orders_path, params: {
      purchase_order: {
        supplier_id: supplier.id,
        destination_store_location_id: store.id,
        lines: [{ product_variant_id: variant.id, quantity: "5", unit_cost: "100.00" }]
      }
    }
    expect(response).to redirect_to(purchase_order_path(PurchaseOrder.last))
    po = PurchaseOrder.last
    expect(po.purchase_order_lines.first.quantity).to eq(5)
    expect(po.subtotal_cents).to eq(50000)

    post submit_purchase_order_path(po)
    expect(po.reload.status.to_s).to eq("submitted")

    post approve_purchase_order_path(po)
    expect(po.reload.status.to_s).to eq("approved")

    line = po.purchase_order_lines.first
    post receive_purchase_order_path(po), params: {
      receive: [{ purchase_order_line_id: line.id, quantity: "5" }]
    }
    expect(po.reload.status.to_s).to eq("received")
    expect(Stock.where(store_location: store, product_variant: variant).first.quantity).to eq(5.0)
  end

  it "cancels a draft PO" do
    po = create(:purchase_order, business: business, supplier: supplier, destination_store_location: store, status: :draft)
    post cancel_purchase_order_path(po)
    expect(po.reload.status.to_s).to eq("cancelled")
  end
end
