class PurchaseReturnLine < ApplicationRecord
  belongs_to :purchase_return
  belongs_to :product_variant

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_cost_cents, numericality: { greater_than_or_equal_to: 0 }
end
