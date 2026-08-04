class CashRegister < ApplicationRecord
  include TenantScoped

  enum :status, { active: 0, inactive: 1 }

  belongs_to :store_location

  has_many :cash_sessions, dependent: :restrict_with_error

  validates :name, :code, presence: true
  validates :code, uniqueness: { scope: :business_id }
end
