require "rails_helper"

RSpec.describe Current, type: :model do
  before { clear_current! }
  after { clear_current! }

  describe ".business" do
    it "returns the signed-in user's business" do
      business = create(:business)
      user = create(:user, business: business)
      sign_in_as(user)

      expect(Current.business).to eq(business)
    end

    it "returns nil when no user is signed in" do
      expect(Current.business).to be_nil
    end
  end

  describe ".business_id" do
    it "returns the signed-in user's business id" do
      business = create(:business)
      user = create(:user, business: business)
      sign_in_as(user)

      expect(Current.business_id).to eq(business.id)
    end

    it "returns nil when no user is signed in" do
      expect(Current.business_id).to be_nil
    end
  end
end
