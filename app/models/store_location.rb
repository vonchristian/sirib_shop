class StoreLocation < ApplicationRecord
  include TenantScoped

  enum :location_type, { warehouse: 0, store: 1 }, prefix: true
  enum :status, { active: 0, inactive: 1 }

  has_many :stocks, dependent: :restrict_with_error
  has_many :cash_registers, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :business_id }

  validate :only_one_active_main_location, if: -> { is_main? && active? }

  def only_one_active_main_location
    if business && business.store_locations.active.where(is_main: true).where.not(id: id).exists?
      errors.add(:is_main, "only one active main location is allowed per business")
    end
  end
end
