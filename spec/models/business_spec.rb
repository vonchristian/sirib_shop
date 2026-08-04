require "rails_helper"

RSpec.describe Business, type: :model do
  subject { create(:business) }

  describe "associations" do
    it { is_expected.to have_many(:store_locations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:customers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:suppliers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:categories).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:products).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:product_variants).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:stocks).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:line_items).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:inventory_items).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:carts).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:sales_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:sales_returns).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:payments).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:purchase_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:purchase_returns).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:transfer_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:work_orders).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:service_asset_categories).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:service_assets).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:cash_registers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:ledgers).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:journal_entries) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:timezone) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_uniqueness_of(:code) }
  end

  describe "#main_location" do
    it "returns the active main store location" do
      main = create(:store_location, business: subject, is_main: true)

      expect(subject.main_location).to eq(main)
    end

    it "returns nil when there is no main location" do
      expect(subject.main_location).to be_nil
    end
  end
end
