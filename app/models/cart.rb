class Cart < ApplicationRecord
  include TenantScoped

  enum :status, { open: 0, converted: 1, abandoned: 2 }

  belongs_to :store_location
  belongs_to :customer, optional: true
  belongs_to :created_by_user, class_name: "User", optional: true

  has_many :cart_lines, dependent: :destroy

  scope :active, -> { where(status: :open) }

  def subtotal_cents
    cart_lines.sum { |line| line.quantity * line.unit_price_cents }.to_i
  end

  def discount_cents
    0
  end

  def total_cents
    subtotal_cents - discount_cents
  end
end
