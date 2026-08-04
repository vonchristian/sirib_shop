class InventoryItem < ApplicationRecord
  include TenantScoped

  enum :status, { available: 0, reserved: 1, sold: 2, repair: 3, damaged: 4, returned: 5 }

  belongs_to :stock
  belongs_to :product_variant

  validates :imei_1, uniqueness: { scope: :business_id }, allow_blank: true
  validates :serial_number, uniqueness: { scope: :business_id }, allow_blank: true

  validate :identifier_required_for_serialized_variant

  private

  def identifier_required_for_serialized_variant
    if product_variant&.track_serial? && imei_1.blank? && imei_2.blank? && serial_number.blank?
      errors.add(:base, "IMEI or serial number is required for serialized products")
    end
  end
end
