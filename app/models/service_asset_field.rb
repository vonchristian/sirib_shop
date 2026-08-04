class ServiceAssetField < ApplicationRecord
  enum :data_type, { text: 0, integer: 1, decimal: 2, date: 3, boolean: 4 }

  belongs_to :service_asset_category
  has_many :service_asset_values, dependent: :destroy

  validates :name, :label, presence: true
  validates :name, uniqueness: { scope: :service_asset_category_id }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }
end
