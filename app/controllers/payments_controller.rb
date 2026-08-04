class PaymentsController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_sales_order

  def new
    @payment = @sales_order.payments.new
  end

  def create
    result = PaymentService.record!(
      order: @sales_order,
      payment_method: params[:payment][:payment_method],
      amount_cents: money_value(params[:payment][:amount]),
      reference: params[:payment][:reference],
      paid_at: Time.current
    )
    if result.created
      redirect_to @sales_order, notice: "Payment recorded."
    else
      flash.now[:alert] = result.errors.to_sentence
      @payment = @sales_order.payments.new
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_sales_order
    @sales_order = SalesOrder.find(params[:sales_order_id])
  end
end
