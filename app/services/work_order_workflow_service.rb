# Work order lifecycle and repair domain operations.
#
# Estimating parts never touches inventory; only actually consuming a part
# creates an `internal_use` movement against the repair location's stock.
class WorkOrderWorkflowService
  Result = Struct.new(:ok, :work_order, :errors, keyword_init: true)

  TRANSITIONS = {
    received: %i[draft diagnosing waiting_for_approval cancelled],
    diagnosing: %i[received waiting_for_approval cancelled],
    waiting_for_approval: %i[approved diagnosing cancelled],
    approved: %i[in_progress waiting_for_parts cancelled],
    in_progress: %i[waiting_for_parts ready_for_release],
    waiting_for_parts: %i[in_progress],
    ready_for_release: %i[released]
  }.freeze

  class << self
    def transition!(work_order, to)
      to = to.to_sym
      allowed = TRANSITIONS.fetch(work_order.status.to_sym, [])
      unless allowed.include?(to)
        return Result.new(ok: false, work_order: work_order, errors: ["cannot move from #{work_order.status} to #{to}"])
      end

      work_order.transaction do
        if to == :released
          unless work_order.all_items_returned?
            return Result.new(ok: false, work_order: work_order, errors: ["all received items must be returned before release"])
          end
          work_order.closed_at = Time.current
        end
        work_order.status = to
        work_order.started_at ||= Time.current if %i[diagnosing in_progress].include?(to)
        work_order.completed_at = Time.current if to == :ready_for_release
        work_order.save!
      end

      Result.new(ok: true, work_order: work_order, errors: [])
    rescue ActiveRecord::RecordInvalid => e
      Result.new(ok: false, work_order: work_order, errors: e.record.errors.full_messages)
    end

    def consume_part!(work_order_part)
      work_order_part.transaction do
        return Result.new(ok: false, work_order: work_order, errors: ["part already consumed"]) if work_order_part.consumed?

        work_order = WorkOrder.lock.find(work_order_part.work_order_id)
        stock = work_order_part.stock || Stock.find_by(store_location: work_order.store_location, product_variant: work_order_part.product_variant)
        if stock.nil?
          raise InventoryMovementService::InsufficientStockError, "no stock record for #{work_order_part.product_variant.display_name} at #{work_order.store_location.name}"
        end

        qty = work_order_part.quantity.to_d

        if work_order_part.product_variant.track_serial?
          raise InventoryMovementService::SerializedQuantityMismatchError, "serialized repair parts require integer quantity" unless qty == qty.to_i

          items = stock.inventory_items.available.limit(qty.to_i)
          if items.count < qty.to_i
            raise InventoryMovementService::InsufficientStockError, "insufficient stock for #{work_order_part.product_variant.display_name}"
          end

          items.each { |item| item.update!(status: :repair) }
        else
          available = stock.quantity - stock.reserved_quantity
          if available < qty
            raise InventoryMovementService::InsufficientStockError, "insufficient stock for #{work_order_part.product_variant.display_name} (#{available} available)"
          end
        end

        InventoryMovementService.move!(
          stock: stock,
          movement_type: :internal_use,
          quantity: -qty,
          reference: work_order,
          unit_cost_cents: work_order_part.product_variant.cost_price_cents,
          occurred_at: Time.current
        )

        work_order_part.update!(consumed: true, stock: stock)
        Result.new(ok: true, work_order: work_order, errors: [])
      end
    rescue InventoryMovementService::InsufficientStockError, InventoryMovementService::SerializedQuantityMismatchError => e
      Result.new(ok: false, work_order: WorkOrder.find(work_order_part.work_order_id), errors: [e.message])
    end

    # Returns an item at release time, recording who returned it and its
    # condition at return.
    def return_service_item!(service_item, returned_by_user:, condition_at_return:)
      service_item.transaction do
        return Result.new(ok: false, work_order: service_item.work_order, errors: ["item already returned"]) if service_item.returned?

        service_item.update!(
          returned_at: Time.current,
          returned_by_user: returned_by_user,
          condition_at_return: condition_at_return.to_s.presence || "good"
        )
        Result.new(ok: true, work_order: service_item.work_order, errors: [])
      end
    rescue ActiveRecord::RecordInvalid => e
      Result.new(ok: false, work_order: service_item.work_order, errors: e.record.errors.full_messages)
    end

    # Adds a received item with the next tag number for the work order.
    def receive_item!(work_order, attributes)
      work_order.transaction do
        sequence = work_order.service_items.count + 1
        item = work_order.service_items.build(
          attributes.merge(
            tag_number: "#{work_order.number}-#{sequence.to_s.rjust(2, "0")}",
            received_at: Time.current
          )
        )
        item.save!
        Result.new(ok: true, work_order: work_order, errors: [])
      end
    rescue ActiveRecord::RecordInvalid => e
      Result.new(ok: false, work_order: work_order, errors: e.record.errors.full_messages)
    end
  end
end
