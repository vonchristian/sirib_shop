require "rails_helper"

RSpec.describe "Catalog resources", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product) }
  let(:category) { create(:category, business: business) }
  let(:store) { create(:store_location, business: business, is_main: true) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "Products" do
    include_examples "a standard crud controller", resource: :product, record_class: Product,
      valid_params: { name: "Phone X", status: "active" },
      invalid_params: { name: "", status: "active" }
  end

  describe "Categories" do
    include_examples "a standard crud controller", resource: :category, record_class: Category,
      valid_params: { name: "Tablets", status: "active" },
      invalid_params: { name: "", status: "active" }
  end

  describe "ProductVariants" do
    it "renders new and creates via the product" do
      get new_product_variant_path(product)
      expect(response).to have_http_status(:ok)

      post product_variants_path(product), params: { product_variant: { name: "128GB", sku: "SKU-1", status: "active" } }
      expect(response).to redirect_to(variant_path(ProductVariant.last))
    end

    it "re-renders new on invalid create" do
      post product_variants_path(product), params: { product_variant: { name: "", sku: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "indexes all variants" do
      get all_variants_path
      expect(response).to have_http_status(:ok)
    end

    it "shows, edits, and updates a variant" do
      get variant_path(variant)
      expect(response).to have_http_status(:ok)

      get edit_variant_path(variant)
      expect(response).to have_http_status(:ok)

      patch variant_path(variant), params: { product_variant: { name: "256GB", status: "active" } }
      expect(response).to redirect_to(variant_path(variant.reload))
    end

    it "re-renders edit on invalid update" do
      patch variant_path(variant), params: { product_variant: { name: "", sku: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Stocks" do
    it "indexes and shows a stock" do
      stock = create(:stock, business: business, store_location: store, product_variant: variant, quantity: 5)
      get stocks_path
      expect(response).to have_http_status(:ok)
      get stock_path(stock)
      expect(response).to have_http_status(:ok)
    end

    it "adjusts stock" do
      stock = create(:stock, business: business, store_location: store, product_variant: variant, quantity: 5)
      post adjust_stocks_path, params: { store_location_id: store.id, product_variant_id: variant.id, movement_type: "adjustment", quantity: "3" }
      expect(response).to redirect_to(stocks_path)
      expect(stock.reload.quantity).to eq(2)
    end

    it "rejects non-positive quantities" do
      post adjust_stocks_path, params: { store_location_id: store.id, product_variant_id: variant.id, movement_type: "adjustment", quantity: "0" }
      expect(response).to redirect_to(stocks_path)
    end
  end
end
