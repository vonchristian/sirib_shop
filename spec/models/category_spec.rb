require "rails_helper"

RSpec.describe Category, type: :model do
  subject { create(:category) }

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:children).class_name("Category").with_foreign_key(:parent_id).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:products).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:business_id).allow_blank }
  end

  describe "code uniqueness scoped to business" do
    it "allows the same code in different businesses" do
      create(:category, code: "SAME")
      expect(build(:category, code: "SAME")).to be_valid
    end
  end

  describe "parent business validation" do
    let!(:business_a) { create(:business) }
    let!(:business_b) { create(:business) }
    let!(:parent_category) { create(:category, business: business_a) }

    it "is invalid when the parent belongs to a different business" do
      child = build(:category, business: business_b, parent: parent_category)

      expect(child).not_to be_valid
      expect(child.errors[:parent]).to include("must belong to the same business")
    end

    it "is valid when the parent belongs to the same business" do
      child = build(:category, business: business_a, parent: parent_category)

      expect(child).to be_valid
    end
  end
end
