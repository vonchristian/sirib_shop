class Admin::BusinessesController < Admin::BaseController
  before_action :set_business, only: %i[show edit update]

  def index
    @businesses = Business.order(:name)
  end

  def show
  end

  def new
    @business = Business.new
  end

  def create
    @business = Business.new(business_params)
    if @business.save
      redirect_to admin_businesses_path, notice: "Business created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @business.update(business_params)
      redirect_to admin_businesses_path, notice: "Business updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_business
    @business = Business.find(params[:id])
  end

  def business_params
    params.require(:business).permit(:name, :legal_name, :code, :tax_identifier, :email, :phone, :timezone, :currency, :status)
  end
end
