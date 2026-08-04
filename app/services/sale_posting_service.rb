# Posts a confirmed sales order: moves inventory out of stock, selects exact
# serialized units, and records the revenue + COGS journal entries.
#
# Idempotent: uses a compare-and-swap on the order status so only one caller
# can transition confirmed -> fulfilled, all inside one transaction.
class SalePostingService
  Result = Struct.new(:posted, :order, :errors, keyword_init: true)

  # inventory_item_ids: optional hash { sales_order_line_id => [inventory_item_id] }
  def self.call(order, inventory_item_ids: {})
    new(order, inventory_item_ids: inventory_item_ids).call
  end

  def initialize(order, inventory_item_ids: {})
    @order = order
    @inventory_item_ids = (inventory_item_ids || {}).transform_keys(&:to_s)
  end

  def call
    SalesOrder.transaction do
      rows = SalesOrder.where(id: @order.id, status: :confirmed)
                       .update_all(status: :fulfilled, fulfilled_at: Time.current)
      return Result.new(posted: false, order: @order, errors: ["order is not confirmable"]) if rows.zero?

      @order = SalesOrder.lock.find(@order.id)

      ledger = AccountingMapper.ledger_for(@order.business)

      post_lines!
      post_revenue_entry!(ledger)
      post_cogs_entry!(ledger)

      @order.update!(status: :completed) if @order.outstanding_balance_cents <= 0

      Result.new(posted: true, order: @order, errors: [])
    end
  rescue InventoryMovementService::InsufficientStockError, InventoryMovementService::SerializedQuantityMismatchError, JournalPostingService::UnbalancedError => e
    Result.new(posted: false, order: @order, errors: [e.message])
  end

  private

  def post_lines!
    @order.sales_order_lines.each do |line|
      stock = Stock.find_or_create_by!(store_location: @order.store_location, product_variant: line.product_variant)
      qty = line.quantity.to_d

      if line.product_variant.track_serial?
        raise InventoryMovementService::SerializedQuantityMismatchError, "serialized sale must have integer quantity" unless qty == qty.to_i

        items = select_serialized_items(stock, line, qty.to_i)
        sell_serialized_items!(items)
      end

      InventoryMovementService.move!(
        stock: stock,
        movement_type: :sale,
        quantity: -qty,
        reference: @order,
        unit_cost_cents: line.product_variant.cost_price_cents,
        occurred_at: @order.ordered_at
      )
    end
  end

  def select_serialized_items(stock, line, needed)
    ids = @inventory_item_ids[line.id.to_s] || @inventory_item_ids[line.id.to_i] || []
    items =
      if ids.any?
        stock.inventory_items.where(id: ids, status: :available)
      else
        stock.inventory_items.available.order(:id).limit(needed)
      end

    raise InventoryMovementService::InsufficientStockError, "insufficient serialized inventory for #{line.product_variant.display_name}" if items.count < needed

    items.limit(needed).to_a
  end

  def sell_serialized_items!(items)
    items.each do |item|
      item.update!(status: :sold, sold_at: Time.current)
    end
  end

  def post_revenue_entry!(ledger)
    return if @order.sales_order_lines.empty?

    total = @order.total_cents
    return if total <= 0

    JournalPostingService.post!(
      ledger: ledger,
      reference: @order,
      description: "Sale #{@order.number}",
      occurred_at: @order.ordered_at,
      lines: [
        { account: AccountingMapper.account(ledger, :accounts_receivable), debit_cents: total,
          description: "Sale #{@order.number}" },
        { account: AccountingMapper.account(ledger, :phone_sales), credit_cents: total,
          description: "Sale #{@order.number}" }
      ]
    )
  end

  def post_cogs_entry!(ledger)
    total_cogs = @order.sales_order_lines.sum do |line|
      (line.quantity.to_d * line.product_variant.cost_price_cents).to_i
    end
    return if total_cogs <= 0

    JournalPostingService.post!(
      ledger: ledger,
      reference: @order,
      description: "COGS for #{@order.number}",
      occurred_at: @order.ordered_at,
      lines: [
        { account: AccountingMapper.account(ledger, :cogs), debit_cents: total_cogs,
          description: "COGS for #{@order.number}" },
        { account: AccountingMapper.account(ledger, :inventory), credit_cents: total_cogs,
          description: "COGS for #{@order.number}" }
      ]
    )
  end
end
