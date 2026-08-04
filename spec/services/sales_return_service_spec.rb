require "rails_helper"

RSpec.describe SalesReturnService do
  let(:business) { create(:business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:customer) { create(:customer, business: business) }
  let(:user) { create(:user, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product, cost_price_cents: 500_00) }
  let(:order) do
    so = SalesOrder.new(
      business: business, store_location: store, customer: customer, created_by_user: user,
      number: "SO-RT", status: :confirmed, ordered_at: Time.current,
      subtotal_cents: 1200_00, total_cents: 1200_00
    )
    so.save!
    so
  end
  let(:sales_return) do
    sr = create(:sales_return, business: business, sales_order: order, store_location: store)
    create(:sales_return_line, sales_return: sr, product_variant: variant, quantity: 1, unit_price_cents: 1200_00)
    sr
  end

  before do
    Current.user = create(:user, business: business)
    create(:stock, business: business, store_location: store, product_variant: variant, quantity: 0)
  end

  it "completes a return and posts the reversal journal entry" do
    ledger = AccountingMapper.ledger_for(business)
    result = SalesReturnService.call(sales_return)
    expect(result.completed).to be true
    expect(sales_return.reload.status.to_s).to eq("completed")
    reversal = JournalEntry.where(ledger: ledger).where("description LIKE ?", "Sales return%").first
    expect(reversal).not_to be_nil
  end

  it "refuses to complete a non-open return" do
    sales_return.update!(status: :completed)
    result = SalesReturnService.call(sales_return)
    expect(result.completed).to be false
    expect(result.errors).to include("return is not completable")
  end
end
