require "rails_helper"

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, inactive: 1) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:business) }
    it { is_expected.to have_many(:created_sales_orders).class_name("SalesOrder").with_foreign_key(:created_by_user_id).dependent(:nullify) }
    it { is_expected.to have_many(:created_purchase_orders).class_name("PurchaseOrder").with_foreign_key(:created_by_user_id).dependent(:nullify) }
    it { is_expected.to have_many(:created_transfer_orders).class_name("TransferOrder").with_foreign_key(:created_by_user_id).dependent(:nullify) }
    it { is_expected.to have_many(:created_carts).class_name("Cart").with_foreign_key(:created_by_user_id).dependent(:nullify) }
    it { is_expected.to have_many(:assigned_work_orders).class_name("WorkOrder").with_foreign_key(:assigned_user_id).dependent(:nullify) }
    it { is_expected.to have_many(:cash_sessions).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:business_id) }
    it { is_expected.to allow_value("manager@example.com").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }
  end

  describe "email uniqueness scoped to business" do
    it "allows the same email in different businesses" do
      create(:user, email: "duplicate@example.com")
      expect(build(:user, email: "duplicate@example.com")).to be_valid
    end
  end

  describe "password authentication" do
    it "authenticates with the correct password" do
      user = create(:user, password: "password123")

      expect(user.authenticate("password123")).to be_truthy
      expect(user.authenticate("wrong-password")).to be_falsey
    end
  end
end
