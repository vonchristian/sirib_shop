class PurchaseOrderLine < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :product_variant

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_cost_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :received_quantity, numericality: { greater_than_or_equal_to: 0 }

  def outstanding_quantity
    quantity - received_quantity
  end
end
