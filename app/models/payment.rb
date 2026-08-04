class Payment < ApplicationRecord
  include TenantScoped

  enum :payment_method, { cash: 0, bank_transfer: 1, card: 2, gcash: 3, maya: 4, other: 5 }
  enum :status, { pending: 0, completed: 1, failed: 2, voided: 3 }

  belongs_to :sales_order
  belongs_to :cash_session, optional: true

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :paid_at, presence: true
end
