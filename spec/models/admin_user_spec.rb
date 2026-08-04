require "rails_helper"

RSpec.describe AdminUser, type: :model do
  subject { create(:admin_user) }

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, inactive: 1) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value("admin@example.com").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }
  end

  describe "password authentication" do
    it "authenticates with the correct password" do
      admin = create(:admin_user, password: "password123")

      expect(admin.authenticate("password123")).to be_truthy
      expect(admin.authenticate("wrong-password")).to be_falsey
    end
  end
end
