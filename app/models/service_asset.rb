class ServiceAsset < ApplicationRecord
  include TenantScoped

  belongs_to :customer
  belongs_to :service_asset_category

  has_many :service_asset_values, dependent: :destroy
  has_many :work_orders, dependent: :restrict_with_error

  validates :name, presence: true

  validate :customer_belongs_to_same_business
  validate :category_belongs_to_same_business

  scope :ordered, -> { order(:name) }

  def display_name
    "#{name} (#{service_asset_category.name})"
  end

  def value_for(field)
    service_asset_values.find_by(service_asset_field: field)
  end

  def self.search(term)
    return all if term.blank?

    where("service_assets.name ILIKE ?", "%#{term.strip}%")
      .or(where(id: ServiceAssetValue.where("text_value ILIKE ?", "%#{term.strip}%").select(:service_asset_id)))
  end

  private

  def customer_belongs_to_same_business
    if customer_id && customer.business_id != business_id
      errors.add(:customer, "must belong to the same business")
    end
  end

  def category_belongs_to_same_business
    if service_asset_category_id && service_asset_category.business_id != business_id
      errors.add(:service_asset_category, "must belong to the same business")
    end
  end
end
