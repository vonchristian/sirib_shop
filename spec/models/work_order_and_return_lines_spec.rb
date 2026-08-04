require "rails_helper"

RSpec.describe WorkOrderPart, type: :model do
  it "computes total_cents" do
    p = WorkOrderPart.new(quantity: 3, unit_price_cents: 500)
    expect(p.total_cents).to eq(1500)
  end
end

RSpec.describe WorkOrderService, type: :model do
  it "computes total_cents" do
    s = WorkOrderService.new(quantity: 2, unit_price_cents: 1000)
    expect(s.total_cents).to eq(2000)
  end

  it "requires a name" do
    s = build(:work_order_service, name: nil)
    expect(s).not_to be_valid
  end
end

RSpec.describe WorkOrderTask, type: :model do
  it "requires a description" do
    t = build(:work_order_task, description: nil)
    expect(t).not_to be_valid
  end
end

RSpec.describe Charge, type: :model do
  it "requires a description" do
    c = build(:charge, description: nil)
    expect(c).not_to be_valid
  end
end

RSpec.describe ServiceItem, type: :model do
  it "is not returned until returned_at is set" do
    item = build(:service_item)
    expect(item).not_to be_returned
    item.returned_at = Time.current
    expect(item).to be_returned
  end
end

RSpec.describe SalesReturnLine, type: :model do
  it "requires quantity > 0" do
    line = build(:sales_return_line, quantity: 0)
    expect(line).not_to be_valid
  end
end

RSpec.describe PurchaseReturnLine, type: :model do
  it "requires quantity > 0" do
    line = build(:purchase_return_line, quantity: 0)
    expect(line).not_to be_valid
  end
end
