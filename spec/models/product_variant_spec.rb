require "rails_helper"

RSpec.describe ProductVariant, type: :model do
  subject { create(:product_variant) }

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:product) }
    it { is_expected.to have_many(:stocks).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:inventory_items).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:sku) }
    it { is_expected.to validate_uniqueness_of(:sku).scoped_to(:business_id) }
    it { is_expected.to validate_numericality_of(:selling_price_cents).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:cost_price_cents).is_greater_than_or_equal_to(0) }
  end

  describe "sku uniqueness scoped to business" do
    it "allows the same sku in different businesses" do
      create(:product_variant, sku: "SKU-SAME")
      expect(build(:product_variant, sku: "SKU-SAME")).to be_valid
    end
  end

  describe "#display_name" do
    it "combines the product name and variant name" do
      product = create(:product, name: "T-Shirt")
      variant = create(:product_variant, name: "Small", product: product)

      expect(variant.display_name).to eq("T-Shirt - Small")
    end
  end
end
