# Moves inventory between store locations.
#
# - Ship: origin stock decreases and the transfer shows as in-transit.
#   Serialized items move to the destination stock as `reserved`.
# - Receive: destination stock increases; serialized items become available.
#
# Both steps are compare-and-swap guarded so a retry cannot double-move stock.
class TransferService
  Result = Struct.new(:ok, :transfer_order, :errors, keyword_init: true)

  def self.ship(transfer_order)
    TransferOrder.transaction do
      rows = TransferOrder.where(id: transfer_order.id, status: :approved)
                          .update_all(status: :shipped, shipped_at: Time.current)
      return Result.new(ok: false, transfer_order: transfer_order, errors: ["transfer is not shippable"]) if rows.zero?

      transfer_order = TransferOrder.lock.find(transfer_order.id)

      transfer_order.transfer_order_lines.each do |line|
        origin_stock = Stock.find_or_create_by!(store_location: transfer_order.origin_store_location, product_variant: line.product_variant)
        qty = line.quantity.to_d

        if line.product_variant.track_serial?
          items = select_available_items(origin_stock, line, qty.to_i)
          move_items_to_transit!(items, transfer_order)
        end

        InventoryMovementService.move!(
          stock: origin_stock,
          movement_type: :transfer,
          quantity: -qty,
          reference: transfer_order,
          occurred_at: transfer_order.shipped_at
        )
      end

      Result.new(ok: true, transfer_order: transfer_order, errors: [])
    end
  rescue InventoryMovementService::InsufficientStockError => e
    Result.new(ok: false, transfer_order: transfer_order, errors: [e.message])
  end

  def self.receive(transfer_order)
    TransferOrder.transaction do
      rows = TransferOrder.where(id: transfer_order.id, status: :shipped)
                          .update_all(status: :received, received_at: Time.current)
      return Result.new(ok: false, transfer_order: transfer_order, errors: ["transfer is not receivable"]) if rows.zero?

      transfer_order = TransferOrder.lock.find(transfer_order.id)

      transfer_order.transfer_order_lines.each do |line|
        destination_stock = Stock.find_or_create_by!(store_location: transfer_order.destination_store_location, product_variant: line.product_variant)
        qty = line.quantity.to_d

        if line.product_variant.track_serial?
          items = destination_stock.inventory_items.where(status: :reserved)
          items.each { |item| item.update!(status: :available) }
        end

        if destination_stock.reserved_quantity > 0
          destination_stock.reserved_quantity = (destination_stock.reserved_quantity - qty).clamp(0, destination_stock.reserved_quantity)
          destination_stock.save!
        end

        InventoryMovementService.move!(
          stock: destination_stock,
          movement_type: :transfer,
          quantity: qty,
          reference: transfer_order,
          occurred_at: transfer_order.received_at
        )

        line.update!(received_quantity: line.quantity)
      end

      Result.new(ok: true, transfer_order: transfer_order, errors: [])
    end
  end

  def self.select_available_items(stock, line, needed)
    items = stock.inventory_items.available
    raise InventoryMovementService::InsufficientStockError, "insufficient serialized inventory to transfer for #{line.product_variant.display_name}" if items.count < needed

    items.limit(needed).to_a
  end

  def self.move_items_to_transit!(items, transfer_order)
    destination_stock = Stock.find_or_create_by!(store_location: transfer_order.destination_store_location, product_variant: items.first.product_variant)
    items.each do |item|
      item.update!(stock: destination_stock, status: :reserved)
    end
    destination_stock.reserved_quantity = (destination_stock.reserved_quantity + items.size).round(3)
    destination_stock.save!
  end
end
