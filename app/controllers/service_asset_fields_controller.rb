class ServiceAssetFieldsController < ApplicationController
  before_action :require_business_user
  before_action :set_category
  before_action :set_field, only: %i[edit update destroy]

  def new
    @field = @category.service_asset_fields.build
  end

  def create
    @field = @category.service_asset_fields.build(field_params)
    if @field.save
      redirect_to @category, notice: "Field added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @field.update(field_params)
      redirect_to @category, notice: "Field updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @field.destroy
      redirect_to @category, notice: "Field removed."
    else
      redirect_to @category, alert: @field.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    if params[:service_asset_category_id]
      @category = ServiceAssetCategory.find(params[:service_asset_category_id])
    elsif params[:id]
      @category = ServiceAssetField.find(params[:id]).service_asset_category
    end
  end

  def set_field
    @field = @category.service_asset_fields.find(params[:id])
  end

  def field_params
    params.require(:service_asset_field).permit(:name, :label, :data_type, :required, :unique, :position, :active)
  end
end
