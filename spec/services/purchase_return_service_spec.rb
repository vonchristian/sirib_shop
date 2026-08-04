require "rails_helper"

RSpec.describe PurchaseReturnService do
  let(:business) { create(:business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:supplier) { create(:supplier, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product) }
  let(:purchase_order) { create(:purchase_order, business: business, supplier: supplier, destination_store_location: store) }
  let(:purchase_return) do
    pr = create(:purchase_return, business: business, purchase_order: purchase_order, supplier: supplier, store_location: store)
    create(:purchase_return_line, purchase_return: pr, product_variant: variant, quantity: 2, unit_cost_cents: 800_00)
    pr
  end

  before { Current.user = create(:user, business: business); create(:stock, business: business, store_location: store, product_variant: variant, quantity: 5) }

  it "completes a return and posts the reversal" do
    ledger = AccountingMapper.ledger_for(business)
    result = PurchaseReturnService.call(purchase_return)
    expect(result.completed).to be true
    expect(purchase_return.reload.status.to_s).to eq("completed")
    reversal = JournalEntry.where(ledger: ledger).where("description LIKE ?", "Purchase return%").first
    expect(reversal).not_to be_nil
  end

  it "refuses a non-open return" do
    purchase_return.update!(status: :completed)
    result = PurchaseReturnService.call(purchase_return)
    expect(result.completed).to be false
    expect(result.errors).to include("return is not completable")
  end
end
