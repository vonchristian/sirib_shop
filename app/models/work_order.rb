class WorkOrder < ApplicationRecord
  include TenantScoped

  enum :status, {
    draft: 0,
    received: 1,
    diagnosing: 2,
    waiting_for_approval: 3,
    approved: 4,
    in_progress: 5,
    waiting_for_parts: 6,
    ready_for_release: 7,
    released: 8,
    cancelled: 9
  }

  enum :priority, { normal: 0, high: 1, urgent: 2 }

  belongs_to :store_location
  belongs_to :customer
  belongs_to :service_asset
  belongs_to :assigned_user, class_name: "User", optional: true

  has_many :work_order_tasks, dependent: :destroy
  has_many :work_order_parts, dependent: :destroy
  has_many :work_order_services, dependent: :destroy
  has_many :charges, dependent: :destroy
  has_many :service_items, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :business_id }
  validates :received_at, presence: true

  validate :customer_matches_service_asset

  scope :open, -> { where.not(status: %i[released cancelled]) }
  scope :ordered, -> { order(received_at: :desc) }

  def total_cents
    charges.sum(:amount_cents)
  end

  def returned_item_count
    service_items.where.not(returned_at: nil).count
  end

  def all_items_returned?
    service_items.none? || service_items.count == returned_item_count
  end

  def service_asset_display
    "#{service_asset.name} (#{service_asset.service_asset_category.name})"
  end

  private

  def customer_matches_service_asset
    if service_asset_id && service_asset.customer_id != customer_id
      errors.add(:customer, "must match the customer of the service asset")
    end
  end
end
