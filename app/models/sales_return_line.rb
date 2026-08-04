class SalesReturnLine < ApplicationRecord
  belongs_to :sales_return
  belongs_to :product_variant

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
end
