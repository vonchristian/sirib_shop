class TransferOrdersController < ApplicationController
  before_action :require_business_user
  before_action :set_transfer_order, only: %i[show approve ship receive cancel]

  def index
    @transfer_orders = TransferOrder.includes(:origin_store_location, :destination_store_location).order(created_at: :desc)
  end

  def show
  end

  def new
    @transfer_order = TransferOrder.new
  end

  def create
    @transfer_order = TransferOrder.new(
      business: current_business,
      origin_store_location_id: params[:transfer_order][:origin_store_location_id],
      destination_store_location_id: params[:transfer_order][:destination_store_location_id],
      created_by_user: current_user,
      number: NumberGenerator.generate("TO-", TransferOrder),
      status: :draft,
      requested_at: Time.current
    )

    Array(params[:transfer_order][:lines]).each do |line|
      variant = ProductVariant.find_by(id: line[:product_variant_id])
      next unless variant

      @transfer_order.transfer_order_lines.build(product_variant: variant, quantity: line[:quantity].to_f)
    end

    if @transfer_order.save
      redirect_to @transfer_order, notice: "Transfer order created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    @transfer_order.update!(status: :approved, approved_at: Time.current) if @transfer_order.draft?
    redirect_to @transfer_order, notice: "Transfer approved."
  end

  def ship
    result = TransferService.ship(@transfer_order)
    if result.ok
      redirect_to @transfer_order, notice: "Transfer shipped; origin stock decreased."
    else
      redirect_to @transfer_order, alert: result.errors.to_sentence
    end
  end

  def receive
    result = TransferService.receive(@transfer_order)
    if result.ok
      redirect_to @transfer_order, notice: "Transfer received; destination stock increased."
    else
      redirect_to @transfer_order, alert: result.errors.to_sentence
    end
  end

  def cancel
    @transfer_order.update!(status: :cancelled) if @transfer_order.draft?
    redirect_to @transfer_order, notice: "Transfer cancelled."
  end

  private

  def set_transfer_order
    @transfer_order = TransferOrder.find(params[:id])
  end
end
