class CashMovement < ApplicationRecord
  enum :movement_type, { sale: 0, refund: 1, cash_in: 2, cash_out: 3, opening: 4, closing: 5, adjustment: 6 }

  belongs_to :cash_session
  belongs_to :reference, polymorphic: true, optional: true

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :occurred_at, presence: true
end
