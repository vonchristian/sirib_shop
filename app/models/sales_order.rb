class SalesOrder < ApplicationRecord
  include TenantScoped

  enum :status, {
    draft: 0,
    confirmed: 1,
    partially_fulfilled: 2,
    fulfilled: 3,
    cancelled: 4,
    completed: 5
  }

  belongs_to :store_location
  belongs_to :customer, optional: true
  belongs_to :created_by_user, class_name: "User", optional: true

  has_many :sales_order_lines, dependent: :destroy
  has_many :payments, dependent: :restrict_with_error
  has_many :sales_returns, dependent: :restrict_with_error

  validates :number, presence: true, uniqueness: { scope: :business_id }
  validates :ordered_at, presence: true
  validates :subtotal_cents, :discount_total_cents, :tax_total_cents, :total_cents,
            numericality: { greater_than_or_equal_to: 0 }

  def outstanding_balance_cents
    total_cents - payments.completed.sum(:amount_cents)
  end
end
