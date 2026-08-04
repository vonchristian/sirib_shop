class Charge < ApplicationRecord
  belongs_to :work_order

  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
