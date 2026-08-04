# Receives purchase order lines into the main store location.
#
# The purchase order itself never changes stock; receiving is what increases
# inventory. For serialized variants, IMEI/serial details are captured on the
# received InventoryItem before it becomes available.
class PurchaseReceivingService
  Result = Struct.new(:received, :purchase_order, :errors, keyword_init: true)

  # lines: array of { purchase_order_line_id:, quantity:, serials: [ {imei_1:, imei_2:, serial_number:} ] }
  def self.call(purchase_order, lines:)
    new(purchase_order, lines: lines).call
  end

  def initialize(purchase_order, lines:)
    @purchase_order = purchase_order
    @lines = lines
  end

  def call
    PurchaseOrder.transaction do
      @purchase_order = PurchaseOrder.lock.find(@purchase_order.id)
      return Result.new(received: false, purchase_order: @purchase_order, errors: ["order is not receivable"]) unless receivable?

      validate_lines!
      receive_lines!

      all_received = @purchase_order.purchase_order_lines.all? { |l| l.received_quantity >= l.quantity }
      @purchase_order.update!(status: all_received ? :received : :partially_received)

      post_receipt_entry!

      Result.new(received: true, purchase_order: @purchase_order, errors: [])
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(received: false, purchase_order: @purchase_order, errors: [e.message])
  rescue InventoryMovementService::SerializedQuantityMismatchError => e
    Result.new(received: false, purchase_order: @purchase_order, errors: [e.message])
  end

  private

  def receivable?
    @purchase_order.approved? || @purchase_order.partially_received?
  end

  def line_params
    @lines.map { |l| l.symbolize_keys }
  end

  def validate_lines!
    line_params.each do |lp|
      pol = @purchase_order.purchase_order_lines.find(lp.fetch(:purchase_order_line_id))
      qty = lp.fetch(:quantity).to_d
      raise ActiveRecord::RecordInvalid.new(pol) if qty <= 0

      if qty > pol.outstanding_quantity + 0.0001
        raise ActiveRecord::RecordInvalid.new(pol), "cannot receive more than the outstanding quantity for #{pol.product_variant.display_name}"
      end

      if pol.product_variant.track_serial?
        raise ActiveRecord::RecordInvalid.new(pol), "must specify IMEI/serial for serialized items" unless qty == qty.to_i
        raise ActiveRecord::RecordInvalid.new(pol), "serials count does not match quantity" if lp[:serials].to_a.size != qty.to_i
      end
    end
  end

  def receive_lines!
    line_params.each do |lp|
      pol = @purchase_order.purchase_order_lines.find(lp.fetch(:purchase_order_line_id))
      qty = lp.fetch(:quantity).to_d
      stock = Stock.find_or_create_by!(store_location: @purchase_order.destination_store_location, product_variant: pol.product_variant)

      create_inventory_items!(pol, stock, lp[:serials].to_a) if pol.product_variant.track_serial?

      InventoryMovementService.move!(
        stock: stock,
        movement_type: :purchase,
        quantity: qty,
        reference: @purchase_order,
        unit_cost_cents: pol.unit_cost_cents,
        occurred_at: Time.current
      )

      pol.received_quantity = (pol.received_quantity + qty).round(3)
      pol.save!
    end
  end

  def create_inventory_items!(pol, stock, serials)
    serials.each do |serial|
      stock.inventory_items.create!(
        business_id: @purchase_order.business_id,
        product_variant: pol.product_variant,
        imei_1: serial[:imei_1],
        imei_2: serial[:imei_2],
        serial_number: serial[:serial_number],
        status: :available,
        received_at: Time.current
      )
    end
  end

  def post_receipt_entry!
    ledger = AccountingMapper.ledger_for(@purchase_order.business)
    total_cost = line_params.sum do |lp|
      pol = @purchase_order.purchase_order_lines.find(lp.fetch(:purchase_order_line_id))
      (lp.fetch(:quantity).to_d * pol.unit_cost_cents).to_i
    end
    return if total_cost <= 0

    JournalPostingService.post!(
      ledger: ledger,
      reference: @purchase_order,
      description: "Receipt for #{@purchase_order.number}",
      occurred_at: Time.current,
      lines: [
        { account: AccountingMapper.account(ledger, :inventory), debit_cents: total_cost,
          description: "Goods received" },
        { account: AccountingMapper.account(ledger, :accounts_payable), credit_cents: total_cost,
          description: "Purchase #{@purchase_order.number}" }
      ]
    )
  end
end
