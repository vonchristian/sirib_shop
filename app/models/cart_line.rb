class CartLine < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :product_variant_id, uniqueness: { scope: :cart_id }

  def line_total_cents
    (quantity * unit_price_cents).round
  end
end
