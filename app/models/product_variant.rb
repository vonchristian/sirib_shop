class ProductVariant < ApplicationRecord
  include TenantScoped

  enum :status, { active: 0, inactive: 1 }

  belongs_to :product

  has_many :stocks, dependent: :restrict_with_error
  has_many :inventory_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: { scope: :business_id }
  validates :selling_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_price_cents, numericality: { greater_than_or_equal_to: 0 }

  def display_name
    "#{product&.name} - #{name}"
  end
end
