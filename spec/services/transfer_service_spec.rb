require "rails_helper"

RSpec.describe TransferService do
  let(:business) { create(:business) }
  let(:origin) { create(:store_location, business: business, is_main: true) }
  let(:destination) { create(:store_location, business: business) }
  let(:product) { create(:product, business: business) }
  let(:variant) { create(:product_variant, business: business, product: product) }

  let(:transfer) do
    t = create(:transfer_order, business: business, origin_store_location: origin, destination_store_location: destination, status: :approved)
    create(:transfer_order_line, transfer_order: t, product_variant: variant, quantity: 3, received_quantity: 0)
    t
  end

  before do
    Current.user = create(:user, business: business)
    create(:stock, business: business, store_location: origin, product_variant: variant, quantity: 10)
  end

  it "ships stock out of origin and marks in-transit" do
    result = TransferService.ship(transfer)
    expect(result.ok).to be true
    expect(transfer.reload.status.to_s).to eq("shipped")
    expect(Stock.find_by(store_location: origin, product_variant: variant).quantity).to eq(7.0)
  end

  it "rejects shipping a non-approved transfer" do
    transfer.update!(status: :draft)
    result = TransferService.ship(transfer)
    expect(result.ok).to be false
    expect(result.errors).to include("transfer is not shippable")
  end

  it "receives stock at destination and marks received" do
    TransferService.ship(transfer)
    result = TransferService.receive(transfer)
    expect(result.ok).to be true
    expect(transfer.reload.status.to_s).to eq("received")
    expect(Stock.find_by(store_location: destination, product_variant: variant).quantity).to eq(3.0)
  end

  it "rejects receiving a non-shipped transfer" do
    result = TransferService.receive(transfer)
    expect(result.ok).to be false
    expect(result.errors).to include("transfer is not receivable")
  end

  context "with a serialized variant" do
    let(:serial_variant) { create(:product_variant, business: business, product: product, track_serial: true) }

    def make_serial_transfer
      t = create(:transfer_order, business: business, origin_store_location: origin, destination_store_location: destination, status: :approved)
      create(:transfer_order_line, transfer_order: t, product_variant: serial_variant, quantity: 2, received_quantity: 0)
      t
    end

    it "moves serialized units into transit and makes them available on receive" do
      origin_stock = create(:stock, business: business, store_location: origin, product_variant: serial_variant, quantity: 2)
      create(:stock, business: business, store_location: destination, product_variant: serial_variant, quantity: 10)
      2.times { create(:inventory_item, business: business, stock: origin_stock, product_variant: serial_variant, imei_1: "IMEI#{rand(99999)}", status: :available) }
      serial_t = make_serial_transfer

      result = TransferService.ship(serial_t)
      expect(result.ok).to be true
      expect(serial_t.reload.status.to_s).to eq("shipped")
      moved = InventoryItem.where(product_variant: serial_variant).where.not(stock: origin_stock)
      expect(moved.count).to eq(2)
      expect(moved.map(&:status).uniq).to eq(["reserved"])

      result = TransferService.receive(serial_t)
      expect(result.ok).to be true
      expect(serial_t.reload.status.to_s).to eq("received")
      expect(InventoryItem.where(product_variant: serial_variant).map(&:status).uniq).to eq(["available"])
    end

    it "returns an error when there is not enough serialized inventory to transfer" do
      create(:stock, business: business, store_location: origin, product_variant: serial_variant, quantity: 0)
      serial_t = make_serial_transfer
      result = TransferService.ship(serial_t)
      expect(result.ok).to be false
      expect(result.errors.first).to include("insufficient serialized inventory")
    end
  end
end
