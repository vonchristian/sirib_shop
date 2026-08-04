class LedgersController < ApplicationController
  before_action :require_business_user
  before_action :set_ledger, only: %i[show]

  def index
    @ledgers = Ledger.order(:name)
  end

  def show
    @accounts = @ledger.accounts.order(:code)
  end

  def new
    @ledger = Ledger.new
  end

  def create
    @ledger = Ledger.new(ledger_params)
    if @ledger.save
      redirect_to @ledger, notice: "Ledger created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_ledger
    @ledger = Ledger.find(params[:id])
  end

  def ledger_params
    params.require(:ledger).permit(:name, :code, :status)
  end
end
