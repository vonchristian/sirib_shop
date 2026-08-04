require "rails_helper"

RSpec.describe MoneyConvertible, type: :controller do
  controller(ApplicationController) { include MoneyConvertible }

  describe "#money_value" do
    before { routes.draw { get "test" => "anonymous#test" } }

    it "converts peso strings to integer cents" do
      controller_instance = controller
      expect(controller_instance.send(:money_value, "100.00")).to eq(10000)
      expect(controller_instance.send(:money_value, "₱1,234.56")).to eq(123456)
      expect(controller_instance.send(:money_value, "0.99")).to eq(99)
    end

    it "returns 0 for blank input" do
      controller_instance = controller
      expect(controller_instance.send(:money_value, nil)).to eq(0)
      expect(controller_instance.send(:money_value, "")).to eq(0)
    end
  end
end
