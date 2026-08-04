class Ledger < ApplicationRecord
  include TenantScoped

  enum :status, { active: 0, inactive: 1 }

  has_many :accounts, dependent: :restrict_with_error
  has_many :journal_entries, dependent: :restrict_with_error

  validates :name, :code, presence: true
  validates :code, uniqueness: { scope: :business_id }
end
