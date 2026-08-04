class PurchaseOrdersController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_purchase_order, only: %i[show submit approve receive cancel]

  def index
    @purchase_orders = PurchaseOrder.includes(:supplier, :destination_store_location).order(ordered_at: :desc)
    @purchase_orders = @purchase_orders.where(status: params[:status]) if params[:status].present?
  end

  def show
  end

  def new
    @purchase_order = PurchaseOrder.new(destination_store_location_id: current_business&.main_location&.id)
  end

  def create
    @purchase_order = PurchaseOrder.new(
      business: current_business,
      supplier_id: params[:purchase_order][:supplier_id],
      destination_store_location_id: params[:purchase_order][:destination_store_location_id],
      created_by_user: current_user,
      number: NumberGenerator.generate("PO-", PurchaseOrder),
      status: :draft,
      ordered_at: Time.current,
      subtotal_cents: 0,
      tax_total_cents: 0,
      total_cents: 0
    )

    build_lines_from_params(@purchase_order)

    if @purchase_order.save
      redirect_to @purchase_order, notice: "Purchase order created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def submit
    @purchase_order.update!(status: :submitted) if @purchase_order.draft?
    redirect_to @purchase_order, notice: "Purchase order submitted."
  end

  def approve
    @purchase_order.update!(status: :approved) if @purchase_order.submitted?
    redirect_to @purchase_order, notice: "Purchase order approved."
  end

  def receive
    if request.get?
      @lines = @purchase_order.purchase_order_lines.includes(:product_variant)
    else
      receive_goods
    end
  end

  def receive_goods
    lines = Array(params[:receive]).map do |line|
      {
        purchase_order_line_id: line[:purchase_order_line_id],
        quantity: line[:quantity].to_f,
        serials: Array(line[:serials]).filter_map { |s| s.permit(:imei_1, :imei_2, :serial_number).to_h.symbolize_keys }
      }
    end

    result = PurchaseReceivingService.call(@purchase_order, lines: lines)
    if result.received
      redirect_to @purchase_order, notice: "Purchase order received; stock updated."
    else
      redirect_to @purchase_order, alert: result.errors.to_sentence
    end
  end

  def cancel
    @purchase_order.update!(status: :cancelled) if @purchase_order.draft? || @purchase_order.submitted?
    redirect_to @purchase_order, notice: "Purchase order cancelled."
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def build_lines_from_params(order)
    Array(params[:purchase_order][:lines]).each do |line|
      variant = ProductVariant.find_by(id: line[:product_variant_id])
      next unless variant

      qty = line[:quantity].to_f
      unit_cost = money_value(line[:unit_cost])
      order.purchase_order_lines.build(
        product_variant: variant,
        quantity: qty,
        unit_cost_cents: unit_cost,
        tax_cents: 0,
        total_cents: (qty * unit_cost).round
      )
      order.subtotal_cents += (qty * unit_cost).round
    end
    order.total_cents = order.subtotal_cents
  end
end
