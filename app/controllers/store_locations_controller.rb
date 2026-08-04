class StoreLocationsController < ApplicationController
  before_action :require_business_user
  before_action :set_store_location, only: %i[show edit update]

  def index
    @store_locations = StoreLocation.order(:name)
  end

  def show
  end

  def new
    @store_location = StoreLocation.new
  end

  def create
    @store_location = StoreLocation.new(store_location_params)
    if @store_location.save
      redirect_to @store_location, notice: "Store location created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @store_location.update(store_location_params)
      redirect_to @store_location, notice: "Store location updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_store_location
    @store_location = StoreLocation.find(params[:id])
  end

  def store_location_params
    params.require(:store_location).permit(:name, :code, :location_type, :is_main, :address, :status)
  end
end
