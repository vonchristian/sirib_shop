require "rails_helper"

RSpec.describe WorkOrderWorkflowService do
  let(:business) { create(:business) }
  let(:store) { create(:store_location, business: business, is_main: true) }
  let(:customer) { create(:customer, business: business) }
  let(:category) { create(:service_asset_category, business: business) }
  let(:asset) { create(:service_asset, business: business, customer: customer, service_asset_category: category) }
  let(:work_order) { create(:work_order, business: business, store_location: store, customer: customer, service_asset: asset, status: :received) }

  describe ".transition!" do
    it "moves along the lifecycle" do
      r1 = WorkOrderWorkflowService.transition!(work_order, :diagnosing)
      expect(r1.ok).to be true
      expect(work_order.reload.status.to_s).to eq("diagnosing")

      WorkOrderWorkflowService.transition!(work_order, :waiting_for_approval)
      WorkOrderWorkflowService.transition!(work_order, :approved)
      WorkOrderWorkflowService.transition!(work_order, :in_progress)
      r5 = WorkOrderWorkflowService.transition!(work_order, :ready_for_release)
      expect(r5.ok).to be true
      expect(work_order.reload.status.to_s).to eq("ready_for_release")
    end

    it "rejects an invalid transition" do
      result = WorkOrderWorkflowService.transition!(work_order, :released)
      expect(result.ok).to be false
      expect(result.errors.first).to match(/cannot move/)
    end

    it "refuses :released unless all received items are returned" do
      work_order.update!(status: :ready_for_release)
      create(:service_item, work_order: work_order)
      result = WorkOrderWorkflowService.transition!(work_order, :released)
      expect(result.ok).to be false
      expect(result.errors.first).to match(/all received items/)
    end

    it "releases when all items are returned" do
      work_order.update!(status: :ready_for_release)
      item = create(:service_item, work_order: work_order)
      item.update!(returned_at: Time.current, condition_at_return: "good")
      result = WorkOrderWorkflowService.transition!(work_order, :released)
      expect(result.ok).to be true
      expect(work_order.reload.closed_at).to be_present
    end
  end

  describe ".receive_item!" do
    it "assigns a tag and records the item" do
      result = WorkOrderWorkflowService.receive_item!(work_order, name: "Phone", condition: :good, quantity: 1)
      expect(result.ok).to be true
      item = work_order.service_items.last
      expect(item.tag_number).to eq("#{work_order.number}-01")
    end
  end

  describe ".return_service_item!" do
    it "marks a returned item" do
      item = create(:service_item, work_order: work_order)
      user = create(:user, business: business)
      result = WorkOrderWorkflowService.return_service_item!(item, returned_by_user: user, condition_at_return: :good)
      expect(result.ok).to be true
      expect(item.reload.returned_at).to be_present
    end

    it "refuses to re-return an item" do
      item = create(:service_item, work_order: work_order, returned_at: Time.current)
      user = create(:user, business: business)
      result = WorkOrderWorkflowService.return_service_item!(item, returned_by_user: user, condition_at_return: :good)
      expect(result.ok).to be false
      expect(result.errors).to include("item already returned")
    end
  end

  describe ".consume_part!" do
    let(:variant) { create(:product_variant, business: business) }

    it "consumes a non-serialized part from stock" do
      create(:stock, business: business, store_location: store, product_variant: variant, quantity: 5)
      part = create(:work_order_part, work_order: work_order, product_variant: variant, quantity: 1, unit_price_cents: 100)
      result = WorkOrderWorkflowService.consume_part!(part)
      expect(result.ok).to be true
      expect(part.reload.consumed).to be true
    end
  end
end
