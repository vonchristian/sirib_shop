require "rails_helper"

RSpec.describe Product, type: :model do
  subject { create(:product) }

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, inactive: 1) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:category).optional }
    it { is_expected.to have_many(:variants).class_name("ProductVariant").dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
