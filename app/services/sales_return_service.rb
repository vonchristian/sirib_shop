# Completes a sales return: puts goods back into stock at the return location
# and reverses the original sale's revenue/COGS journal entries.
class SalesReturnService
  Result = Struct.new(:completed, :sales_return, :errors, keyword_init: true)

  def self.call(sales_return, inventory_item_ids: {})
    ledger = AccountingMapper.ledger_for(sales_return.business)

    SalesReturn.transaction do
      rows = SalesReturn.where(id: sales_return.id, status: :open)
                        .update_all(status: :completed)
      return Result.new(completed: false, sales_return: sales_return, errors: ["return is not completable"]) if rows.zero?

      sales_return = SalesReturn.lock.find(sales_return.id)

      restore_lines!(sales_return, inventory_item_ids.transform_keys(&:to_s))
      post_reversal_entry!(ledger, sales_return)

      Result.new(completed: true, sales_return: sales_return, errors: [])
    end
  rescue InventoryMovementService::InsufficientStockError => e
    Result.new(completed: false, sales_return: sales_return, errors: [e.message])
  end

  def self.restore_lines!(sales_return, inventory_item_ids = {})
    sales_return.sales_return_lines.each do |line|
      stock = Stock.find_or_create_by!(store_location: sales_return.store_location, product_variant: line.product_variant)
      qty = line.quantity.to_d

      if line.product_variant.track_serial?
        items = select_sold_items(stock, line, qty.to_i, inventory_item_ids[line.id.to_s])
        items.each do |item|
          item.update!(status: :available, sold_at: nil)
        end
      end

      InventoryMovementService.move!(
        stock: stock,
        movement_type: :sales_return,
        quantity: qty,
        reference: sales_return,
        unit_cost_cents: line.product_variant.cost_price_cents,
        occurred_at: Time.current
      )
    end
  end

  def self.select_sold_items(stock, line, needed, ids)
    items = ids&.any? ? stock.inventory_items.where(id: ids) : stock.inventory_items.where(status: :sold)
    if items.count < needed
      raise InventoryMovementService::InsufficientStockError, "could not locate #{needed} sold unit(s) to return for #{line.product_variant.display_name}"
    end

    items.limit(needed).to_a
  end

  def self.post_reversal_entry!(ledger, sales_return)
    total = sales_return.sales_return_lines.sum do |line|
      (line.quantity.to_d * line.unit_price_cents).to_i
    end
    return if total <= 0

    JournalPostingService.post!(
      ledger: ledger,
      reference: sales_return,
      description: "Sales return #{sales_return.number}",
      occurred_at: Time.current,
      lines: [
        { account: AccountingMapper.account(ledger, :phone_sales), debit_cents: total,
          description: "Sales return #{sales_return.number}" },
        { account: AccountingMapper.account(ledger, :accounts_receivable), credit_cents: total,
          description: "Sales return #{sales_return.number}" }
      ]
    )
  end
end
