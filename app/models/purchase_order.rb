class PurchaseOrder < ApplicationRecord
  include TenantScoped

  enum :status, {
    draft: 0,
    submitted: 1,
    approved: 2,
    partially_received: 3,
    received: 4,
    cancelled: 5
  }

  belongs_to :supplier
  belongs_to :destination_store_location, class_name: "StoreLocation"
  belongs_to :created_by_user, class_name: "User", optional: true

  has_many :purchase_order_lines, dependent: :destroy
  has_many :purchase_returns, dependent: :restrict_with_error

  validates :number, presence: true, uniqueness: { scope: :business_id }
  validates :ordered_at, presence: true

  validate :destination_must_be_main_location

  scope :receivable, -> { where(status: %i[approved partially_received]) }

  def receivable?
    approved? || partially_received?
  end

  private

  def destination_must_be_main_location
    if destination_store_location && !destination_store_location.is_main?
      errors.add(:destination_store_location, "must be the main receiving location in MVP")
    end
  end
end
