require "rails_helper"

RSpec.describe InventoryMovementService do
  let(:business) { create(:business) }
  let(:store) { create(:store_location, business: business) }
  let(:variant) { create(:product_variant, business: business) }
  let(:stock) { create(:stock, business: business, store_location: store, product_variant: variant, quantity: 10) }

  it "increases stock and creates a line item" do
    result = InventoryMovementService.move!(stock: stock, movement_type: :purchase, quantity: 5, unit_cost_cents: 100)
    expect(result).to be_a(LineItem)
    expect(stock.reload.quantity).to eq(15.0)
    expect(LineItem.where(stock: stock, movement_type: :purchase, quantity: 5)).to exist
  end

  it "decreases stock for a sale" do
    InventoryMovementService.move!(stock: stock, movement_type: :sale, quantity: -3)
    expect(stock.reload.quantity).to eq(7.0)
  end

  it "raises ArgumentError on zero quantity" do
    expect {
      InventoryMovementService.move!(stock: stock, movement_type: :purchase, quantity: 0)
    }.to raise_error(ArgumentError)
  end

  it "builds a non-persisted line item" do
    line = InventoryMovementService.build(stock: stock, movement_type: :sale, quantity: -1)
    expect(line).to be_a(LineItem)
    expect(line).to be_new_record
    expect(line.quantity).to eq(-1)
  end
end
