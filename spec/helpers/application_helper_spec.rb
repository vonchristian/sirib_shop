require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  before do
    helper.define_singleton_method(:current_business) { nil }
  end

  describe "#money" do
    it "formats cents as currency" do
      expect(helper.money(123450)).to eq("PHP 1234.50")
    end

    it "returns em-dash for nil" do
      expect(helper.money(nil)).to eq("—")
    end

    it "accepts an alternate currency" do
      expect(helper.money(100, "USD")).to eq("USD 1.00")
    end
  end

  describe "#money_input_value" do
    it "returns empty string for zero cents" do
      expect(helper.money_input_value(0)).to eq("")
    end

    it "formats cents as decimal" do
      expect(helper.money_input_value(1999)).to eq("19.99")
    end
  end

  describe "#status_badge" do
    it "renders a badge for an active status" do
      record = Struct.new(:status).new("active")
      output = helper.status_badge(record)
      expect(output).to include("Active")
    end
  end
end
