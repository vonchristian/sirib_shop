# Core inventory movement helper.
#
# All stock quantity changes MUST go through this service so that the
# immutable `LineItem` history and the `Stock` balance are updated in the
# same database transaction.
class InventoryMovementService
  class InsufficientStockError < StandardError; end
  class SerializedQuantityMismatchError < StandardError; end

  # quantity is signed: positive adds, negative removes.
  def self.move!(stock:, movement_type:, quantity:, reference: nil, unit_cost_cents: 0, occurred_at: Time.current)
    raise ArgumentError, "quantity cannot be zero" if quantity.to_d.zero?

    stock = Stock.lock.find(stock.id)

    line = LineItem.create!(
      business_id: stock.business_id,
      stock: stock,
      movement_type: movement_type,
      quantity: quantity.to_d,
      unit_cost_cents: unit_cost_cents,
      reference: reference,
      occurred_at: occurred_at
    )

    stock.quantity = (stock.quantity + quantity.to_d).round(3)
    stock.save!

    line
  end

  # Builds (but does not persist) a line item that can be attached to a batch.
  def self.build(stock:, movement_type:, quantity:, reference: nil, unit_cost_cents: 0, occurred_at: Time.current)
    LineItem.new(
      business_id: stock.business_id,
      stock: stock,
      movement_type: movement_type,
      quantity: quantity.to_d,
      unit_cost_cents: unit_cost_cents,
      reference: reference,
      occurred_at: occurred_at
    )
  end
end
