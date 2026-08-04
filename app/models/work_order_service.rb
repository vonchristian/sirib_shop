class WorkOrderService < ApplicationRecord
  belongs_to :work_order

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  def total_cents
    (quantity.to_d * unit_price_cents).round
  end
end
