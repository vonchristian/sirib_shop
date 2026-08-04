class CashRegistersController < ApplicationController
  before_action :require_business_user
  before_action :set_cash_register, only: %i[show edit update]

  def index
    @cash_registers = CashRegister.includes(:store_location).order(:name)
  end

  def show
  end

  def new
    @cash_register = CashRegister.new
  end

  def create
    @cash_register = CashRegister.new(cash_register_params)
    if @cash_register.save
      redirect_to @cash_register, notice: "Cash register created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cash_register.update(cash_register_params)
      redirect_to @cash_register, notice: "Cash register updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_cash_register
    @cash_register = CashRegister.find(params[:id])
  end

  def cash_register_params
    params.require(:cash_register).permit(:name, :code, :store_location_id, :status)
  end
end
