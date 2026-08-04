require "rails_helper"

RSpec.describe "Work orders", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:customer) { create(:customer, business: business) }
  let(:category) { create(:service_asset_category, business: business) }
  let(:asset) { create(:service_asset, business: business, customer: customer, service_asset_category: category) }

  before { sign_in(user) }

  it "lists work orders" do
    wo = create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset)
    get work_orders_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(wo.number)
  end

  it "shows and renders new" do
    wo = create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset)
    get work_order_path(wo)
    expect(response).to have_http_status(:ok)

    get new_work_order_path
    expect(response).to have_http_status(:ok)
  end

  it "creates a work order from a service asset" do
    post work_orders_path, params: { work_order: { service_asset_id: asset.id, store_location_id: store.id, complaint: "broken screen", priority: "normal" } }
    expect(response).to redirect_to(work_order_path(WorkOrder.last))
    expect(WorkOrder.last.service_asset).to eq(asset)
  end

  it "creates a work order with services and parts" do
    product = create(:product, business: business)
    variant = create(:product_variant, business: business, product: product)
    post work_orders_path, params: {
      work_order: {
        service_asset_id: asset.id,
        store_location_id: store.id,
        complaint: "screen",
        services: [{ name: "Diagnosis", quantity: "1", unit_price: "20.00" }],
        parts: [{ product_variant_id: variant.id, quantity: "1", unit_price: "10.00" }]
      }
    }
    expect(response).to redirect_to(work_order_path(WorkOrder.last))
    expect(WorkOrder.last.work_order_services.count).to eq(1)
    expect(WorkOrder.last.work_order_parts.count).to eq(1)
  end

  it "transitions a work order" do
    wo = create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset, status: :received)
    post transition_work_order_path(wo), params: { to: "diagnosing" }
    expect(wo.reload.status.to_s).to eq("diagnosing")
  end

  it "rejects an invalid transition" do
    wo = create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset, status: :received)
    post transition_work_order_path(wo), params: { to: "completed" }
    expect(response).to redirect_to(work_order_path(wo))
  end

  it "adds task, part, service, and charge" do
    wo = create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset)
    post add_task_work_order_path(wo), params: { work_order_task: { description: "Call customer", estimated_minutes: 10 } }
    expect(wo.work_order_tasks.count).to eq(1)

    product = create(:product, business: business)
    variant = create(:product_variant, business: business, product: product)
    post add_part_work_order_path(wo), params: { work_order_part: { product_variant_id: variant.id, quantity: "1", unit_price: "15.00" } }
    expect(wo.work_order_parts.count).to eq(1)

    post add_service_work_order_path(wo), params: { work_order_service: { name: "Screen repair", quantity: "1", unit_price: "50.00" } }
    expect(wo.work_order_services.count).to eq(1)

    post add_charge_work_order_path(wo), params: { charge: { description: "Rush fee", quantity: "1", unit_price: "5.00" } }
    expect(wo.charges.count).to eq(1)
  end

  it "consumes a part from stock" do
    product = create(:product, business: business)
    variant = create(:product_variant, business: business, product: product)
    stock = create(:stock, business: business, store_location: store, product_variant: variant, quantity: 10)
    wo = create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset)
    part = create(:work_order_part, work_order: wo, product_variant: variant, quantity: 2, unit_price_cents: 500)
    post consume_part_work_order_path(wo), params: { work_order_part_id: part.id }
    expect(part.reload.consumed).to be(true)
    expect(stock.reload.quantity).to eq(8)
  end

  it "receives and returns a service item" do
    wo = create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset, status: :ready_for_release)
    post receive_item_work_order_path(wo), params: { service_item: { name: "Phone", condition: "good", quantity: 1 } }
    expect(wo.service_items.count).to eq(1)

    item = wo.service_items.last
    post return_item_work_order_path(wo), params: { service_item_id: item.id, condition_at_return: "good" }
    expect(item.reload.returned_at).to be_present
  end
end
