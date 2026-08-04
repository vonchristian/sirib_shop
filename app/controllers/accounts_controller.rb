class AccountsController < ApplicationController
  before_action :require_business_user
  before_action :set_ledger
  before_action :set_account, only: %i[show edit update]

  def index
    @accounts = @ledger.accounts.order(:code)
  end

  def show
  end

  def new
    @account = @ledger.accounts.new
  end

  def create
    @account = @ledger.accounts.new(account_params)
    if @account.save
      redirect_to ledger_account_path(@ledger, @account), notice: "Account created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to ledger_account_path(@ledger, @account), notice: "Account updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_ledger
    @ledger = Ledger.find(params[:ledger_id])
  end

  def set_account
    @account = @ledger.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:code, :name, :account_type, :normal_balance, :parent_id, :status)
  end
end
