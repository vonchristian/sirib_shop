require "rails_helper"

RSpec.describe Supplier, type: :model do
  subject { create(:supplier) }

  describe "enums" do
    it { is_expected.to define_enum_for(:supplier_type).with_values(wholesale: 0, distributor: 1, manufacturer: 2, service_provider: 3) }
    it { is_expected.to define_enum_for(:status).with_values(active: 0, inactive: 1) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to have_many(:purchase_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:purchase_returns).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:business_id).allow_blank }
  end

  describe "scopes" do
    describe ".active" do
      it "returns only active suppliers" do
        active = create(:supplier, status: :active)
        inactive = create(:supplier, status: :inactive)

        expect(Supplier.active).to include(active)
        expect(Supplier.active).not_to include(inactive)
      end
    end
  end

  describe "code uniqueness scoped to business" do
    it "allows the same code in different businesses" do
      create(:supplier, code: "SAME")
      expect(build(:supplier, code: "SAME")).to be_valid
    end
  end
end
