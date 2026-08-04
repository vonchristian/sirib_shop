require "rails_helper"

RSpec.describe PurchaseReceivingService do
  let(:business) { create(:business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:supplier) { create(:supplier, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product) }
  let(:user) { create(:user, business: business) }

  before { Current.user = user }

  def make_po(status: :approved, qty: 10)
    po = create(:purchase_order, business: business, supplier: supplier, destination_store_location: store, status: status)
    line = create(:purchase_order_line, purchase_order: po, product_variant: variant, quantity: qty, received_quantity: 0)
    [po, line]
  end

  it "receives full quantity and marks order received" do
    po, line = make_po
    result = PurchaseReceivingService.call(po, lines: [{ purchase_order_line_id: line.id, quantity: 10 }])
    expect(result.received).to be true
    expect(po.reload.status.to_s).to eq("received")
    expect(line.reload.received_quantity).to eq(10)
    expect(Stock.where(store_location: store, product_variant: variant).first.quantity).to eq(10.0)
  end

  it "marks partially received when receiving less than full quantity" do
    po, line = make_po
    result = PurchaseReceivingService.call(po, lines: [{ purchase_order_line_id: line.id, quantity: 4 }])
    expect(result.received).to be true
    expect(po.reload.status.to_s).to eq("partially_received")
    expect(line.reload.received_quantity).to eq(4)
  end

  it "refuses to receive an unapproved order" do
    po, line = make_po(status: :draft)
    result = PurchaseReceivingService.call(po, lines: [{ purchase_order_line_id: line.id, quantity: 5 }])
    expect(result.received).to be false
    expect(result.errors).to include("order is not receivable")
  end

  it "refuses to receive more than the outstanding quantity" do
    po, line = make_po
    result = PurchaseReceivingService.call(po, lines: [{ purchase_order_line_id: line.id, quantity: 99 }])
    expect(result.received).to be false
    expect(result.errors.first).to match(/outstanding/i)
  end
end
