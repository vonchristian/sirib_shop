require "rails_helper"

RSpec.describe Customer, type: :model do
  let!(:business_a) { create(:business) }
  let!(:business_b) { create(:business) }
  let!(:user_a) { create(:user, business: business_a) }

  after { clear_current! }

  describe "default scope" do
    it "does not expose records belonging to another business" do
      customer_b = create(:customer, business: business_b)
      sign_in_as(user_a)

      expect(Customer.exists?(customer_b.id)).to be false
      expect { Customer.find(customer_b.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "exposes records belonging to the current business" do
      customer_a = create(:customer, business: business_a)
      sign_in_as(user_a)

      expect(Customer.exists?(customer_a.id)).to be true
    end
  end

  describe "business validation" do
    it "is invalid when business_id differs from the current business" do
      sign_in_as(user_a)
      customer = Customer.new(name: "Stray", business_id: business_b.id)

      expect(customer).not_to be_valid
      expect(customer.errors[:business_id]).to include("must match the current business")
    end

    it "raises on save when business_id differs from the current business" do
      sign_in_as(user_a)
      customer = Customer.new(name: "Stray", business_id: business_b.id)

      expect { customer.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "is valid when business_id matches the current business" do
      sign_in_as(user_a)
      customer = Customer.new(name: "Match", business_id: business_a.id)

      expect(customer).to be_valid
    end
  end

  describe "auto-assignment of business" do
    it "assigns the current business when business_id is blank" do
      sign_in_as(user_a)
      customer = Customer.new(name: "Auto-assigned")

      expect(customer).to be_valid
      expect(customer.business_id).to eq(business_a.id)
    end

    it "persists the auto-assigned business" do
      sign_in_as(user_a)
      customer = Customer.create!(name: "Persisted")

      expect(customer.reload.business_id).to eq(business_a.id)
    end
  end
end
