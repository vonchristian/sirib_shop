require "rails_helper"

RSpec.describe "Carts", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:variant) { create(:product_variant, business: business, selling_price_cents: 1000_00) }

  before { sign_in(user) }

  it "opens a cart, adds a line, and checks out to a sales order" do
    post carts_path, params: { cart: { store_location_id: store.id, customer_id: "" } }
    expect(response).to redirect_to(cart_path(Cart.last))
    cart = Cart.last
    expect(cart.status.to_s).to eq("open")

    post add_line_cart_path(cart), params: { product_variant_id: variant.id, quantity: "2" }
    expect(response).to redirect_to(cart_path(cart))
    expect(cart.cart_lines.last.quantity.to_i).to eq(2)
    expect(cart.cart_lines.last.unit_price_cents).to eq(1000_00)

    post convert_cart_path(cart)
    expect(response).to redirect_to(sales_order_path(SalesOrder.last))
    expect(cart.reload.status.to_s).to eq("converted")
    expect(SalesOrder.last.total_cents).to eq(2000_00)
  end

  it "refuses checkout of an empty cart" do
    cart = create(:cart, business: business, store_location: store, created_by_user: user, status: :open)
    post convert_cart_path(cart)
    expect(cart.reload.status.to_s).to eq("open")
  end
end
