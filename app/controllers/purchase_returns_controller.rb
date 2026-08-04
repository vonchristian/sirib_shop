class PurchaseReturnsController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_purchase_return, only: %i[show complete]

  def index
    @purchase_returns = PurchaseReturn.includes(:purchase_order, :supplier, :store_location).order(created_at: :desc)
  end

  def show
  end

  def new
    @purchase_return = PurchaseReturn.new(purchase_order_id: params[:purchase_order_id])
  end

  def create
    @purchase_return = PurchaseReturn.new(
      business: current_business,
      purchase_order_id: params[:purchase_return][:purchase_order_id],
      supplier_id: params[:purchase_return][:supplier_id],
      store_location_id: params[:purchase_return][:store_location_id],
      reason: params[:purchase_return][:reason],
      number: NumberGenerator.generate("PR-", PurchaseReturn),
      status: :open
    )

    Array(params[:purchase_return][:lines]).each do |line|
      variant = ProductVariant.find_by(id: line[:product_variant_id])
      next unless variant

      @purchase_return.purchase_return_lines.build(
        product_variant: variant,
        quantity: line[:quantity].to_f,
        unit_cost_cents: money_value(line[:unit_cost])
      )
    end

    if @purchase_return.save
      redirect_to @purchase_return, notice: "Purchase return created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def complete
    result = PurchaseReturnService.call(@purchase_return, inventory_item_ids: params[:inventory_item_ids] || {})
    if result.completed
      redirect_to @purchase_return, notice: "Return completed; stock returned to supplier."
    else
      redirect_to @purchase_return, alert: result.errors.to_sentence
    end
  end

  private

  def set_purchase_return
    @purchase_return = PurchaseReturn.find(params[:id])
  end
end
