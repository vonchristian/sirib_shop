require "rails_helper"

RSpec.describe Customer, type: :model do
  subject { create(:customer) }

  describe "enums" do
    it { is_expected.to define_enum_for(:customer_type).with_values(individual: 0, business: 1, government: 2) }
    it { is_expected.to define_enum_for(:status).with_values(active: 0, inactive: 1) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:children).class_name("Customer").with_foreign_key(:parent_id).dependent(:nullify) }
    it { is_expected.to have_many(:sales_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:work_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:service_assets).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:business_id).allow_blank }
  end

  describe "scopes" do
    describe ".active" do
      it "returns only active customers" do
        active = create(:customer, status: :active)
        inactive = create(:customer, status: :inactive)

        expect(Customer.active).to include(active)
        expect(Customer.active).not_to include(inactive)
      end
    end
  end

  describe "code uniqueness scoped to business" do
    it "allows the same code in different businesses" do
      create(:customer, code: "SAME")
      expect(build(:customer, code: "SAME")).to be_valid
    end
  end
end
