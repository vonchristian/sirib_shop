require "rails_helper"

RSpec.describe InventoryItem, type: :model do
  subject { create(:inventory_item) }

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(available: 0, reserved: 1, sold: 2, repair: 3, damaged: 4, returned: 5) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:stock) }
    it { is_expected.to belong_to(:product_variant) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:imei_1).scoped_to(:business_id).allow_blank }
    it { is_expected.to validate_uniqueness_of(:serial_number).scoped_to(:business_id).allow_blank }
  end

  describe "imei_1 uniqueness scoped to business" do
    it "is invalid when imei_1 is duplicated within the same business" do
      business = create(:business)
      create(:inventory_item, business: business, imei_1: "IMEI-DUP")

      duplicate = build(:inventory_item, business: business, imei_1: "IMEI-DUP")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:imei_1]).to be_present
    end

    it "allows the same imei_1 in different businesses" do
      create(:inventory_item, imei_1: "IMEI-SAME")

      expect(build(:inventory_item, imei_1: "IMEI-SAME")).to be_valid
    end
  end

  describe "serial_number uniqueness scoped to business" do
    it "is invalid when serial_number is duplicated within the same business" do
      business = create(:business)
      create(:inventory_item, business: business, serial_number: "SN-DUP")

      duplicate = build(:inventory_item, business: business, serial_number: "SN-DUP")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:serial_number]).to be_present
    end

    it "allows the same serial_number in different businesses" do
      create(:inventory_item, serial_number: "SN-SAME")

      expect(build(:inventory_item, serial_number: "SN-SAME")).to be_valid
    end
  end

  describe "identifier required for serialized variant" do
    let!(:serialized_variant) { create(:product_variant, track_serial: true) }
    let!(:stock) { create(:stock, product_variant: serialized_variant) }

    it "is invalid for a track_serial variant without any identifier" do
      item = build(:inventory_item, stock: stock, product_variant: serialized_variant,
                                    imei_1: nil, imei_2: nil, serial_number: nil)

      expect(item).not_to be_valid
      expect(item.errors[:base]).to include("IMEI or serial number is required for serialized products")
    end

    it "is valid for a track_serial variant with imei_1" do
      item = build(:inventory_item, stock: stock, product_variant: serialized_variant, imei_1: "IMEI-123")

      expect(item).to be_valid
    end

    it "is valid for a non-serialized variant without an identifier" do
      item = build(:inventory_item)

      expect(item).to be_valid
    end
  end
end
