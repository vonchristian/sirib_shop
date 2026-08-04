class SalesOrderLine < ApplicationRecord
  belongs_to :sales_order
  belongs_to :product_variant

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :discount_cents, :tax_cents, :total_cents, numericality: { greater_than_or_equal_to: 0 }

  def line_total_cents
    (unit_price_cents * quantity - discount_cents + tax_cents).to_i
  end
end
