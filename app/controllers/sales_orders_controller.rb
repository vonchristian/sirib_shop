class SalesOrdersController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_sales_order, only: %i[show post complete cancel]

  def index
    @sales_orders = SalesOrder.includes(:customer, :store_location).order(ordered_at: :desc)
    @sales_orders = @sales_orders.where(status: params[:status]) if params[:status].present?
  end

  def show
    @payments = @sales_order.payments.order(paid_at: :desc)
  end

  def post
    result = SalePostingService.call(@sales_order, inventory_item_ids: params[:inventory_item_ids])
    if result.posted
      redirect_to @sales_order, notice: "Sale posted; inventory updated."
    else
      redirect_to @sales_order, alert: result.errors.to_sentence
    end
  end

  def complete
    if @sales_order.outstanding_balance_cents <= 0
      @sales_order.update!(status: :completed)
      redirect_to @sales_order, notice: "Order completed."
    else
      redirect_to @sales_order, alert: "Order still has an outstanding balance."
    end
  end

  def cancel
    @sales_order.update!(status: :cancelled) if @sales_order.draft? || @sales_order.confirmed?
    redirect_to @sales_order, notice: "Order cancelled."
  end

  private

  def set_sales_order
    @sales_order = SalesOrder.find(params[:id])
  end
end
