class Supplier < ApplicationRecord
  include TenantScoped

  enum :supplier_type, { wholesale: 0, distributor: 1, manufacturer: 2, service_provider: 3 }
  enum :status, { active: 0, inactive: 1 }

  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :purchase_returns, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, uniqueness: { scope: :business_id }, allow_blank: true

  before_validation :normalize_code

  scope :active, -> { where(status: :active) }

  private

  def normalize_code
    self.code = nil if code.blank?
  end
end
