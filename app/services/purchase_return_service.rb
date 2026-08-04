# Completes a purchase return: sends goods back to the supplier (decreases
# main-store stock) and reverses the original purchase entry.
class PurchaseReturnService
  Result = Struct.new(:completed, :purchase_return, :errors, keyword_init: true)

  def self.call(purchase_return, inventory_item_ids: {})
    ledger = AccountingMapper.ledger_for(purchase_return.business)

    PurchaseReturn.transaction do
      rows = PurchaseReturn.where(id: purchase_return.id, status: :open)
                           .update_all(status: :completed)
      return Result.new(completed: false, purchase_return: purchase_return, errors: ["return is not completable"]) if rows.zero?

      purchase_return = PurchaseReturn.lock.find(purchase_return.id)

      return_lines!(purchase_return, inventory_item_ids.transform_keys(&:to_s))
      post_reversal_entry!(ledger, purchase_return)

      Result.new(completed: true, purchase_return: purchase_return, errors: [])
    end
  rescue InventoryMovementService::InsufficientStockError => e
    Result.new(completed: false, purchase_return: purchase_return, errors: [e.message])
  end

  def self.return_lines!(purchase_return, inventory_item_ids = {})
    purchase_return.purchase_return_lines.each do |line|
      stock = Stock.find_or_create_by!(store_location: purchase_return.store_location, product_variant: line.product_variant)
      qty = line.quantity.to_d

      if line.product_variant.track_serial?
        items = select_available_items(stock, line, qty.to_i, inventory_item_ids[line.id.to_s])
        items.each { |item| item.update!(status: :returned) }
      end

      InventoryMovementService.move!(
        stock: stock,
        movement_type: :purchase_return,
        quantity: -qty,
        reference: purchase_return,
        unit_cost_cents: line.unit_cost_cents,
        occurred_at: Time.current
      )
    end
  end

  def self.select_available_items(stock, line, needed, ids)
    items = ids&.any? ? stock.inventory_items.where(id: ids) : stock.inventory_items.available
    if items.count < needed
      raise InventoryMovementService::InsufficientStockError, "could not locate #{needed} available unit(s) to return for #{line.product_variant.display_name}"
    end

    items.limit(needed).to_a
  end

  def self.post_reversal_entry!(ledger, purchase_return)
    total = purchase_return.purchase_return_lines.sum do |line|
      (line.quantity.to_d * line.unit_cost_cents).to_i
    end
    return if total <= 0

    JournalPostingService.post!(
      ledger: ledger,
      reference: purchase_return,
      description: "Purchase return #{purchase_return.number}",
      occurred_at: Time.current,
      lines: [
        { account: AccountingMapper.account(ledger, :accounts_payable), debit_cents: total,
          description: "Purchase return #{purchase_return.number}" },
        { account: AccountingMapper.account(ledger, :inventory), credit_cents: total,
          description: "Purchase return #{purchase_return.number}" }
      ]
    )
  end
end
