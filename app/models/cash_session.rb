class CashSession < ApplicationRecord
  enum :status, { open: 0, closing: 1, closed: 2 }

  belongs_to :cash_register
  belongs_to :user

  has_many :cash_movements, dependent: :restrict_with_error
  has_many :payments, dependent: :nullify

  validates :opened_at, presence: true
  validates :opening_amount_cents, numericality: { greater_than_or_equal_to: 0 }

  validate :single_open_session_per_register, on: :create

  scope :open_sessions, -> { where(status: %i[open closing]) }

  def cash_sales_amount_cents
    cash_movements.where(movement_type: :sale).sum(:amount_cents)
  end

  def cash_refunds_amount_cents
    cash_movements.where(movement_type: :refund).sum(:amount_cents)
  end

  def cash_ins_amount_cents
    cash_movements.where(movement_type: :cash_in).sum(:amount_cents)
  end

  def cash_outs_amount_cents
    cash_movements.where(movement_type: :cash_out).sum(:amount_cents)
  end

  private

  def single_open_session_per_register
    if cash_register && cash_register.cash_sessions.open_sessions.exists?
      errors.add(:base, "this register already has an open session")
    end
  end
end
