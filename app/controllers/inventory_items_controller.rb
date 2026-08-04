class InventoryItemsController < ApplicationController
  before_action :require_business_user
  before_action :set_inventory_item, only: %i[show update_status]

  def index
    @inventory_items = InventoryItem.includes(:stock, :product_variant).order(:id)
    @inventory_items = @inventory_items.where(status: params[:status]) if params[:status].present?
    @inventory_items = @inventory_items.where(product_variant_id: params[:product_variant_id]) if params[:product_variant_id].present?
  end

  def show
  end

  def update_status
    if @inventory_item.update(status: params[:inventory_item][:status])
      redirect_to @inventory_item, notice: "Unit status updated."
    else
      redirect_to @inventory_item, alert: @inventory_item.errors.full_messages.to_sentence
    end
  end

  private

  def set_inventory_item
    @inventory_item = InventoryItem.find(params[:id])
  end
end
