require "rails_helper"

RSpec.describe CartLine, type: :model do
  let(:cart) { create(:cart) }
  let(:variant) { create(:product_variant, business: cart.business) }

  it "computes line_total_cents" do
    line = CartLine.new(quantity: 3, unit_price_cents: 500)
    expect(line.line_total_cents).to eq(1500)
  end

  it "validates quantity > 0" do
    line = build(:cart_line, cart: cart, product_variant: variant, quantity: 0)
    expect(line).not_to be_valid
  end

  it "enforces uniqueness per cart" do
    create(:cart_line, cart: cart, product_variant: variant)
    dup = build(:cart_line, cart: cart, product_variant: variant)
    expect(dup).not_to be_valid
  end
end

RSpec.describe SalesOrderLine, type: :model do
  it "computes line_total_cents with discount and tax" do
    line = SalesOrderLine.new(quantity: 2, unit_price_cents: 1000, discount_cents: 100, tax_cents: 50)
    expect(line.line_total_cents).to eq(1950)
  end
end

RSpec.describe PurchaseOrderLine, type: :model do
  it "computes outstanding_quantity" do
    line = PurchaseOrderLine.new(quantity: 10, received_quantity: 3)
    expect(line.outstanding_quantity).to eq(7)
  end
end

RSpec.describe TransferOrderLine, type: :model do
  it "computes outstanding_quantity" do
    line = TransferOrderLine.new(quantity: 5, received_quantity: 2)
    expect(line.outstanding_quantity).to eq(3)
  end
end
