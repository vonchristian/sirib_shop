class Stock < ApplicationRecord
  include TenantScoped

  belongs_to :store_location
  belongs_to :product_variant

  has_many :line_items, dependent: :restrict_with_error
  has_many :inventory_items, dependent: :restrict_with_error

  validates :store_location_id, uniqueness: { scope: :product_variant_id }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { greater_than_or_equal_to: 0 }
  validate :reserved_cannot_exceed_quantity

  def available_quantity
    quantity - reserved_quantity
  end

  private

  def reserved_cannot_exceed_quantity
    if reserved_quantity && quantity && reserved_quantity > quantity
      errors.add(:reserved_quantity, "cannot exceed quantity")
    end
  end
end
