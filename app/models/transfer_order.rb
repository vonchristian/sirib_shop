class TransferOrder < ApplicationRecord
  include TenantScoped

  enum :status, {
    draft: 0,
    requested: 1,
    approved: 2,
    shipped: 3,
    received: 4,
    completed: 5,
    cancelled: 6
  }

  belongs_to :origin_store_location, class_name: "StoreLocation"
  belongs_to :destination_store_location, class_name: "StoreLocation"
  belongs_to :created_by_user, class_name: "User", optional: true

  has_many :transfer_order_lines, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :business_id }
  validate :origin_and_destination_must_differ

  private

  def origin_and_destination_must_differ
    if origin_store_location_id && destination_store_location_id &&
       origin_store_location_id == destination_store_location_id
      errors.add(:destination_store_location, "must be different from the origin location")
    end
  end
end
