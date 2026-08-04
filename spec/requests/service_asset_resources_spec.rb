require "rails_helper"

RSpec.describe "Service asset resources", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }
  let(:customer) { create(:customer, business: business) }
  let(:category) { create(:service_asset_category, business: business) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "ServiceAssetCategories" do
    include_examples "a standard crud controller", resource: :service_asset_category, record_class: ServiceAssetCategory,
      valid_params: { name: "Phones", description: "Phones", active: true },
      invalid_params: { name: "", active: true }
  end

  describe "ServiceAssets" do
    it "indexes, shows, and renders new" do
      asset = create(:service_asset, business: business, customer: customer, service_asset_category: category)
      get service_assets_path
      expect(response).to have_http_status(:ok)

      get service_asset_path(asset)
      expect(response).to have_http_status(:ok)

      get new_service_asset_path
      expect(response).to have_http_status(:ok)
    end

    it "creates and shows" do
      post service_assets_path, params: { service_asset: { customer_id: customer.id, service_asset_category_id: category.id, name: "Phone-1" } }
      expect(response).to redirect_to(service_asset_path(ServiceAsset.last))
      get service_asset_path(ServiceAsset.last)
      expect(response).to have_http_status(:ok)
    end

    it "re-renders new on invalid create" do
      post service_assets_path, params: { service_asset: { customer_id: nil, service_asset_category_id: nil, name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "ServiceAssetFields" do
    it "renders new and creates a field" do
      get new_service_asset_category_field_path(category)
      expect(response).to have_http_status(:ok)

      post service_asset_category_fields_path(category), params: { service_asset_field: { name: "imei", label: "IMEI", data_type: "text", required: true, active: true } }
      expect(response).to redirect_to(service_asset_category_path(category))
    end

    it "edits and updates a field" do
      field = create(:service_asset_field, service_asset_category: category)
      get edit_field_path(field)
      expect(response).to have_http_status(:ok)

      patch field_path(field), params: { service_asset_field: { label: "Serial" } }
      expect(response).to redirect_to(service_asset_category_path(category))
    end

    it "destroys a field" do
      field = create(:service_asset_field, service_asset_category: category)
      delete field_path(field)
      expect(response).to redirect_to(service_asset_category_path(category))
      expect(ServiceAssetField.exists?(field.id)).to be(false)
    end
  end
end
