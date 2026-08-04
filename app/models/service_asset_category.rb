class ServiceAssetCategory < ApplicationRecord
  include TenantScoped

  has_many :service_asset_fields, dependent: :destroy
  has_many :service_assets, dependent: :restrict_with_error

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
