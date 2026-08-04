class ServiceAssetCategoriesController < ApplicationController
  before_action :require_business_user
  before_action :set_category, only: %i[show edit update]

  def index
    @categories = ServiceAssetCategory.includes(:service_asset_fields, :service_assets).order(:name)
  end

  def show
  end

  def new
    @category = ServiceAssetCategory.new
  end

  def create
    @category = ServiceAssetCategory.new(category_params)
    if @category.save
      redirect_to @category, notice: "Category created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to @category, notice: "Category updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = ServiceAssetCategory.find(params[:id])
  end

  def category_params
    params.require(:service_asset_category).permit(:name, :description, :active)
  end
end
