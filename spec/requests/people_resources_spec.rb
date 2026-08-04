require "rails_helper"

RSpec.describe "Customer & supplier resources", type: :request do
  let(:business) { create(:business) }
  let(:user) { create(:user, business: business) }

  before do
    Current.user = user
    sign_in(user)
  end

  describe "Customers" do
    include_examples "a standard crud controller", resource: :customer, record_class: Customer,
      valid_params: { name: "Alice", customer_type: "individual", status: "active" },
      invalid_params: { name: "", customer_type: "individual" }
  end

  describe "Suppliers" do
    include_examples "a standard crud controller", resource: :supplier, record_class: Supplier,
      valid_params: { name: "Acme Parts", supplier_type: "wholesale", status: "active" },
      invalid_params: { name: "", supplier_type: "wholesale" }
  end

  describe "StoreLocations" do
    include_examples "a standard crud controller", resource: :store_location, record_class: StoreLocation,
      valid_params: { name: "Branch", code: "BR-#{rand(9999)}", location_type: "store", is_main: false, status: "active" },
      invalid_params: { name: "", location_type: "store" }
  end

  describe "Users" do
    include_examples "a standard crud controller", resource: :user, record_class: User,
      valid_params: { name: "Clerk", email: "clerk#{rand(9999)}@x.com", password: "password123", password_confirmation: "password123", status: "active" },
      invalid_params: { name: "", email: "" }
  end
end
