class SalesReturnsController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_sales_return, only: %i[show complete]

  def index
    @sales_returns = SalesReturn.includes(:sales_order, :store_location).order(created_at: :desc)
  end

  def show
  end

  def new
    @sales_return = SalesReturn.new(sales_order_id: params[:sales_order_id], store_location_id: params[:store_location_id])
  end

  def create
    @sales_return = SalesReturn.new(
      business: current_business,
      sales_order_id: params[:sales_return][:sales_order_id],
      store_location_id: params[:sales_return][:store_location_id],
      reason: params[:sales_return][:reason],
      number: NumberGenerator.generate("RET-", SalesReturn),
      status: :open
    )

    lines = Array(params[:sales_return][:lines])
    lines.each do |line|
      variant = ProductVariant.find_by(id: line[:product_variant_id])
      next unless variant

      @sales_return.sales_return_lines.build(
        product_variant: variant,
        quantity: line[:quantity].to_f,
        unit_price_cents: money_value(line[:unit_price])
      )
    end

    if @sales_return.save
      redirect_to @sales_return, notice: "Sales return created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def complete
    result = SalesReturnService.call(@sales_return, inventory_item_ids: params[:inventory_item_ids] || {})
    if result.completed
      redirect_to @sales_return, notice: "Return completed; inventory restored."
    else
      redirect_to @sales_return, alert: result.errors.to_sentence
    end
  end

  private

  def set_sales_return
    @sales_return = SalesReturn.find(params[:id])
  end
end
