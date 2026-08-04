require "rails_helper"

RSpec.describe StoreLocation, type: :model do
  subject { create(:store_location) }

  describe "enums" do
    it { is_expected.to define_enum_for(:location_type).with_values(warehouse: 0, store: 1).with_prefix(:location_type) }
    it { is_expected.to define_enum_for(:status).with_values(active: 0, inactive: 1) }
  end

  describe "location_type prefixed predicate methods" do
    it "exposes warehouse? and store?" do
      warehouse = build(:store_location, location_type: :warehouse)
      store = build(:store_location, location_type: :store)

      expect(warehouse.location_type_warehouse?).to be true
      expect(warehouse.location_type_store?).to be false
      expect(store.location_type_store?).to be true
      expect(store.location_type_warehouse?).to be false
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to have_many(:stocks).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:cash_registers).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:business_id) }
  end

  describe "code uniqueness scoped to business" do
    it "allows the same code in different businesses" do
      create(:store_location, code: "LOC-SAME")
      expect(build(:store_location, code: "LOC-SAME")).to be_valid
    end
  end

  describe "only one active main location" do
    let!(:business) { create(:business) }

    it "is invalid when another active main location already exists" do
      create(:store_location, business: business, is_main: true)
      second = build(:store_location, business: business, is_main: true)

      expect(second).not_to be_valid
      expect(second.errors[:is_main]).to include("only one active main location is allowed per business")
    end

    it "is valid when it is the first active main location" do
      expect(build(:store_location, business: business, is_main: true)).to be_valid
    end

    it "allows an active non-main location alongside a main location" do
      create(:store_location, business: business, is_main: true)

      expect(build(:store_location, business: business, is_main: false)).to be_valid
    end

    it "allows a second main location when the existing one is inactive" do
      create(:store_location, business: business, is_main: true, status: :inactive)

      expect(build(:store_location, business: business, is_main: true, status: :active)).to be_valid
    end
  end
end
