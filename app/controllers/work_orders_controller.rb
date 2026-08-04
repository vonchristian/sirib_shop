class WorkOrdersController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_work_order, only: %i[show transition consume_part receive_item return_item add_task add_part add_service add_charge]

  def index
    @work_orders = WorkOrder.includes(:customer, :service_asset, :store_location, :assigned_user).ordered
    @work_orders = @work_orders.where(status: params[:status]) if params[:status].present?
  end

  def show
  end

  def new
    @work_order = WorkOrder.new
  end

  def create
    service_asset = ServiceAsset.find(params[:work_order][:service_asset_id])

    @work_order = WorkOrder.new(
      business: current_business,
      store_location_id: params[:work_order][:store_location_id],
      customer: service_asset.customer,
      service_asset: service_asset,
      assigned_user_id: params[:work_order][:assigned_user_id].presence,
      number: NumberGenerator.generate("WO-", WorkOrder),
      status: :received,
      priority: params[:work_order][:priority].presence || "normal",
      received_at: Time.current,
      complaint: params[:work_order][:complaint],
      notes: params[:work_order][:notes]
    )

    build_services(@work_order)
    build_parts(@work_order)

    if @work_order.save
      redirect_to @work_order, notice: "Work order created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def transition
    result = WorkOrderWorkflowService.transition!(@work_order, params[:to])
    if result.ok
      redirect_to @work_order, notice: "Work order moved to #{@work_order.status.to_s.titleize}."
    else
      redirect_to @work_order, alert: result.errors.to_sentence
    end
  end

  def consume_part
    part = @work_order.work_order_parts.find(params[:work_order_part_id])
    result = WorkOrderWorkflowService.consume_part!(part)
    if result.ok
      redirect_to @work_order, notice: "Part consumed from stock."
    else
      redirect_to @work_order, alert: result.errors.to_sentence
    end
  end

  def receive_item
    result = WorkOrderWorkflowService.receive_item!(@work_order, item_params)
    if result.ok
      redirect_to @work_order, notice: "Received item tagged."
    else
      redirect_to @work_order, alert: result.errors.to_sentence
    end
  end

  def return_item
    item = @work_order.service_items.find(params[:service_item_id])
    result = WorkOrderWorkflowService.return_service_item!(
      item,
      returned_by_user: current_user,
      condition_at_return: params[:condition_at_return]
    )
    if result.ok
      redirect_to @work_order, notice: "Item returned."
    else
      redirect_to @work_order, alert: result.errors.to_sentence
    end
  end

  def add_task
    @work_order.work_order_tasks.create!(task_params)
    redirect_to @work_order, notice: "Task added."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @work_order, alert: e.record.errors.full_messages.to_sentence
  end

  def add_part
    variant = ProductVariant.find(params[:work_order_part][:product_variant_id])
    @work_order.work_order_parts.create!(
      product_variant: variant,
      quantity: params[:work_order_part][:quantity].to_f,
      unit_price_cents: money_value(params[:work_order_part][:unit_price]).presence || variant.selling_price_cents,
      consumed: false
    )
    redirect_to @work_order, notice: "Part added to estimate."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @work_order, alert: e.record.errors.full_messages.to_sentence
  end

  def add_service
    @work_order.work_order_services.create!(
      name: params[:work_order_service][:name],
      description: params[:work_order_service][:description],
      quantity: params[:work_order_service][:quantity].to_f,
      unit_price_cents: money_value(params[:work_order_service][:unit_price])
    )
    redirect_to @work_order, notice: "Service added."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @work_order, alert: e.record.errors.full_messages.to_sentence
  end

  def add_charge
    @work_order.charges.create!(charge_params)
    redirect_to @work_order, notice: "Charge added."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @work_order, alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_work_order
    @work_order = WorkOrder.find(params[:id])
  end

  def build_services(order)
    Array(params[:work_order][:services]).each do |svc|
      name = svc[:name].presence
      next unless name

      order.work_order_services.build(
        name: name,
        description: svc[:description],
        quantity: svc[:quantity].to_f.positive? ? svc[:quantity].to_f : 1,
        unit_price_cents: money_value(svc[:unit_price])
      )
    end
  end

  def build_parts(order)
    Array(params[:work_order][:parts]).each do |part|
      variant = ProductVariant.find_by(id: part[:product_variant_id])
      next unless variant

      qty = part[:quantity].to_f
      order.work_order_parts.build(
        product_variant: variant,
        quantity: qty.positive? ? qty : 1,
        unit_price_cents: money_value(part[:unit_price]).presence || variant.selling_price_cents,
        consumed: false
      )
    end
  end

  def item_params
    params.require(:service_item).permit(:name, :description, :serial_number, :quantity, :condition, :notes)
  end

  def task_params
    params.require(:work_order_task).permit(:description, :assigned_user_id, :estimated_minutes)
  end

  def charge_params
    qty = params[:charge][:quantity].to_f
    unit_price = money_value(params[:charge][:unit_price])
    params.require(:charge).permit(:description).merge(
      quantity: qty.positive? ? qty : 1,
      unit_price_cents: unit_price,
      amount_cents: (qty.positive? ? qty : 1) * unit_price
    )
  end
end
