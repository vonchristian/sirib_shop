class CashSessionsController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_cash_session, only: %i[show close add_cash]

  def index
    @cash_sessions = CashSession.includes(:cash_register, :user).order(opened_at: :desc)
  end

  def show
  end

  def new
    @cash_session = CashSession.new
  end

  def create
    result = CashSessionService.open!(
      cash_register: CashRegister.find(params[:cash_session][:cash_register_id]),
      user: current_user,
      opening_amount_cents: money_value(params[:cash_session][:opening_amount])
    )
    if result.ok
      redirect_to result.cash_session, notice: "Cash session opened."
    else
      flash.now[:alert] = result.errors.to_sentence
      @cash_session = CashSession.new
      render :new, status: :unprocessable_entity
    end
  end

  def add_cash
    result = CashSessionService.add_cash!(
      @cash_session,
      movement_type: params[:movement_type],
      amount_cents: money_value(params[:amount])
    )
    if result.ok
      redirect_to @cash_session, notice: "Cash movement recorded."
    else
      redirect_to @cash_session, alert: result.errors.to_sentence
    end
  end

  def close
    result = CashSessionService.close!(@cash_session, actual_closing_amount_cents: money_value(params[:actual_closing_amount]))
    if result.ok
      redirect_to @cash_session, notice: "Session closed."
    else
      redirect_to @cash_session, alert: result.errors.to_sentence
    end
  end

  private

  def set_cash_session
    @cash_session = CashSession.find(params[:id])
  end
end
