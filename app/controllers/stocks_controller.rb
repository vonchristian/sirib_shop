class StocksController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_stock, only: %i[show]

  def index
    @stocks = Stock.includes(:store_location, :product_variant).order(:product_variant_id)
    @stocks = @stocks.where(store_location_id: params[:store_location_id]) if params[:store_location_id].present?
    @stocks = @stocks.where(product_variant_id: params[:product_variant_id]) if params[:product_variant_id].present?
    @stocks = @stocks.where("quantity <= ?", params[:low]) if params[:low].present?
  end

  def show
  end

  def adjust
    stock = Stock.find_or_create_by!(store_location_id: params[:store_location_id], product_variant_id: params[:product_variant_id])
    movement_type = params[:movement_type]
    quantity = params[:quantity].to_d
    sign = %w[spoilage internal_use adjustment].include?(movement_type) ? -1 : 1
    sign = -1 if params[:direction] == "out"

    if quantity <= 0
      redirect_to stocks_path, alert: "Quantity must be positive."
      return
    end

    begin
      InventoryMovementService.move!(
        stock: stock,
        movement_type: movement_type,
        quantity: sign * quantity,
        unit_cost_cents: money_value(params[:unit_cost]),
        occurred_at: Time.current
      )
      redirect_to stocks_path, notice: "Stock adjusted."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to stocks_path, alert: e.message
    end
  end

  private

  def set_stock
    @stock = Stock.find(params[:id])
  end
end
