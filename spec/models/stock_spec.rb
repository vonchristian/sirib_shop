require "rails_helper"

RSpec.describe Stock, type: :model do
  subject { create(:stock) }

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:store_location) }
    it { is_expected.to belong_to(:product_variant) }
    it { is_expected.to have_many(:line_items).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:inventory_items).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:store_location_id).scoped_to(:product_variant_id) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:reserved_quantity).is_greater_than_or_equal_to(0) }
  end

  describe "uniqueness" do
    it "is invalid with the same store location and product variant" do
      stock = create(:stock)
      duplicate = build(:stock, store_location: stock.store_location, product_variant: stock.product_variant)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:store_location_id]).to be_present
    end

    it "allows the same store location for different product variants" do
      location = create(:store_location)
      create(:stock, store_location: location)

      expect(build(:stock, store_location: location)).to be_valid
    end
  end

  describe "reserved quantity validation" do
    it "is invalid when reserved_quantity exceeds quantity" do
      stock = build(:stock, quantity: 5, reserved_quantity: 6)

      expect(stock).not_to be_valid
      expect(stock.errors[:reserved_quantity]).to include("cannot exceed quantity")
    end

    it "is valid when reserved_quantity is equal to quantity" do
      expect(build(:stock, quantity: 5, reserved_quantity: 5)).to be_valid
    end
  end

  describe "#available_quantity" do
    it "subtracts reserved_quantity from quantity" do
      stock = build(:stock, quantity: 10, reserved_quantity: 3)

      expect(stock.available_quantity).to eq(7)
    end
  end
end
