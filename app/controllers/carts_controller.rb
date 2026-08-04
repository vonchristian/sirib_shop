class CartsController < ApplicationController
  before_action :require_business_user
  before_action :set_cart, only: %i[show add_line remove_line convert]

  def index
    @carts = Cart.open.includes(:store_location, :customer, :created_by_user).order(created_at: :desc)
  end

  def show
  end

  def new
    @cart = Cart.new
  end

  def create
    @cart = Cart.new(
      store_location_id: params[:cart][:store_location_id],
      customer_id: params[:cart][:customer_id],
      created_by_user: current_user,
      status: :open
    )
    if @cart.save
      redirect_to @cart, notice: "Cart opened."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def add_line
    variant = ProductVariant.find(params[:product_variant_id])
    unit_price = params[:unit_price].to_f * 100
    unit_price = variant.selling_price_cents if unit_price <= 0

    line = @cart.cart_lines.find_or_initialize_by(product_variant: variant)
    line.quantity = (line.persisted? ? line.quantity : 0) + params[:quantity].to_f
    line.unit_price_cents = unit_price.round

    if line.save
      redirect_to @cart, notice: "Line added."
    else
      redirect_to @cart, alert: line.errors.full_messages.to_sentence
    end
  end

  def remove_line
    @cart.cart_lines.find(params[:cart_line_id]).destroy
    redirect_to @cart, notice: "Line removed."
  end

  def convert
    if @cart.cart_lines.empty?
      redirect_to @cart, alert: "Cart is empty."
      return
    end

    SalesOrder.transaction do
      order = SalesOrder.create!(
        business: current_business,
        store_location: @cart.store_location,
        customer: @cart.customer,
        created_by_user: current_user,
        number: NumberGenerator.generate("SO-", SalesOrder),
        status: :confirmed,
        ordered_at: Time.current,
        subtotal_cents: 0,
        discount_total_cents: 0,
        tax_total_cents: 0,
        total_cents: 0
      )

      subtotal = 0
      @cart.cart_lines.each do |cart_line|
        line_total = (cart_line.quantity * cart_line.unit_price_cents).round
        subtotal += line_total
        order.sales_order_lines.create!(
          product_variant: cart_line.product_variant,
          quantity: cart_line.quantity,
          unit_price_cents: cart_line.unit_price_cents,
          discount_cents: 0,
          tax_cents: 0,
          total_cents: line_total
        )
      end

      order.update!(subtotal_cents: subtotal, total_cents: subtotal)
      @cart.update!(status: :converted)

      redirect_to sales_order_path(order), notice: "Cart converted to sales order."
    end
  end

  private

  def set_cart
    @cart = Cart.find(params[:id])
  end
end
