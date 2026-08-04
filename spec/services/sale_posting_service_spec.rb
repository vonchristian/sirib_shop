require "rails_helper"

RSpec.describe SalePostingService do
  let(:business) { create(:business) }
  let(:store) { create(:store_location, business: business) }
  let(:user) { create(:user, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product, cost_price_cents: 500_00, selling_price_cents: 800_00) }
  let!(:stock) { create(:stock, business: business, store_location: store, product_variant: variant, quantity: 5) }

  def make_order(status: :confirmed)
    o = SalesOrder.new(
      business: business, store_location: store, customer: nil,
      created_by_user: user, number: "SO-#{SecureRandom.hex(3)}",
      status: status, ordered_at: Time.current,
      subtotal_cents: 1600_00, discount_total_cents: 0, tax_total_cents: 0, total_cents: 1600_00
    )
    o.save!
    o.sales_order_lines.create!(product_variant: variant, quantity: 2, unit_price_cents: 800_00, discount_cents: 0, tax_cents: 0, total_cents: 1600_00)
    o
  end

  it "posts a confirmed order, decrements stock, and posts revenue/COGS journal entries" do
    Current.user = user
    order = make_order
    ledger = AccountingMapper.ledger_for(business)

    result = SalePostingService.call(order)
    expect(result.posted).to be true
    expect(order.reload.status.to_s).to eq("fulfilled")
    expect(stock.reload.quantity).to eq(3.0)

    revenue = JournalEntry.where(ledger: ledger, description: "Sale #{order.number}").first
    expect(revenue).to be_present
    expect(revenue.journal_lines.sum(:debit_cents)).to eq(1600_00)

    cogs = JournalEntry.where(ledger: ledger, description: "COGS for #{order.number}").first
    expect(cogs).to be_present
    expect(cogs.journal_lines.sum(:debit_cents)).to eq(1000_00) # 2 * 500_00
  end

  it "rejects orders that are not confirmed" do
    order = make_order(status: :draft)
    result = SalePostingService.call(order)
    expect(result.posted).to be false
    expect(result.errors).to include("order is not confirmable")
    expect(stock.reload.quantity).to eq(5.0)
  end

  it "raises when stock is short" do
    order = make_order
    Current.user = user
    stock.update!(quantity: 1)
    expect { SalePostingService.call(order) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
