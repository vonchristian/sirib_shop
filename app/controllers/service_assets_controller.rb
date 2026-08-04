class ServiceAssetsController < ApplicationController
  before_action :require_business_user
  before_action :set_service_asset, only: %i[show]

  def index
    @service_assets = ServiceAsset.includes(:customer, :service_asset_category).search(params[:q]).ordered
    @service_assets = @service_assets.where(service_asset_category_id: params[:service_asset_category_id]) if params[:service_asset_category_id].present?
  end

  def show
    @work_orders = @service_asset.work_orders.includes(:store_location, :assigned_user).order(received_at: :desc)
  end

  def new
    @service_asset = ServiceAsset.new
    @service_asset.service_asset_category_id = params[:service_asset_category_id]
  end

  def create
    @service_asset = ServiceAsset.new(
      business: current_business,
      customer_id: params[:service_asset][:customer_id],
      service_asset_category_id: params[:service_asset][:service_asset_category_id],
      name: params[:service_asset][:name]
    )

    ServiceAsset.transaction do
      @service_asset.save!
      build_values(@service_asset)
    end

    redirect_to @service_asset, notice: "Service asset created."
  rescue ActiveRecord::RecordInvalid => e
    @service_asset = e.record.is_a?(ServiceAsset) ? e.record : @service_asset
    render :new, status: :unprocessable_entity
  end

  private

  def set_service_asset
    @service_asset = ServiceAsset.find(params[:id])
  end

  def build_values(asset)
    category = asset.service_asset_category
    return unless category

    category.service_asset_fields.active.ordered.each do |field|
      raw = params.dig(:service_asset_values, field.id.to_s)
      next if raw.blank? && !field.required

      value = asset.service_asset_values.build(service_asset_field: field)
      value.value = typed_value(field.data_type, raw)
      value.save!
    end
  end

  def typed_value(data_type, raw)
    case data_type
    when "integer" then raw.to_s.delete(",").to_i
    when "decimal" then raw.to_s.delete(",").to_f
    when "date" then raw.presence
    when "boolean" then raw == "1"
    else raw
    end
  end
end
