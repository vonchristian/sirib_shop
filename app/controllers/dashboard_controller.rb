class DashboardController < ApplicationController
  before_action :require_login

  def index
    if current_admin_user
      redirect_to admin_businesses_path
    else
      @stats = {
        today_sales_cents: sales_orders.where(status: %i[fulfilled completed]).where(ordered_at: Time.current.beginning_of_day..Time.current.end_of_day).sum(:total_cents),
        open_orders: sales_orders.where(status: %i[confirmed partially_fulfilled]).count,
        low_stock: stocks.where("quantity <= ?", 5).count,
        open_work_orders: work_orders.where(status: %w[received diagnosing awaiting_approval approved repairing testing]).count,
        open_cash_sessions: open_cash_sessions_count,
        receivable_purchase_orders: purchase_orders.receivable.count
      }
      @recent_sales = sales_orders.order(ordered_at: :desc).limit(5)
      @low_stock_items = stocks.includes(product_variant: :product).where("quantity <= ?", 5).order(:quantity).limit(8)
    end
  end

  private

  def sales_orders
    SalesOrder.where(business: current_business)
  end

  def stocks
    Stock.where(business: current_business)
  end

  def work_orders
    WorkOrder.where(business: current_business)
  end

  def purchase_orders
    PurchaseOrder.where(business: current_business)
  end

  def open_cash_sessions_count
    CashSession.open_sessions.joins(cash_register: :store_location)
               .where(store_locations: { business_id: current_business.id })
               .count
  end
end
