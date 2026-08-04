class ProductVariantsController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_product_variant, only: %i[show edit update]

  def index
    @product_variants = ProductVariant.includes(product: :category).order(:sku)
  end

  def show
  end

  def new
    @product = Product.find(params[:product_id])
    @product_variant = @product.variants.new
  end

  def create
    @product = Product.find(params[:product_id])
    @product_variant = @product.variants.new(variant_params)

    if @product_variant.save
      redirect_to variant_path(@product_variant), notice: "Variant created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product_variant.update(variant_params)
      redirect_to variant_path(@product_variant), notice: "Variant updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_product_variant
    @product_variant = ProductVariant.find(params[:id])
  end

  def variant_params
    p = params.require(:product_variant).permit(:sku, :barcode, :name, :unit, :track_serial, :status, :cost_price, :selling_price)
    p[:cost_price_cents] = money_value(p.delete(:cost_price))
    p[:selling_price_cents] = money_value(p.delete(:selling_price))
    p
  end
end
