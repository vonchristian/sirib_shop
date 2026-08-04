class Business < ApplicationRecord
  enum :status, { active: 0, inactive: 1, suspended: 2 }

  has_many :store_locations, dependent: :restrict_with_error
  has_many :users, dependent: :restrict_with_error
  has_many :customers, dependent: :restrict_with_error
  has_many :suppliers, dependent: :restrict_with_error
  has_many :categories, dependent: :restrict_with_error
  has_many :products, dependent: :restrict_with_error
  has_many :product_variants, dependent: :restrict_with_error
  has_many :stocks, dependent: :restrict_with_error
  has_many :line_items, dependent: :restrict_with_error
  has_many :inventory_items, dependent: :restrict_with_error
  has_many :carts, dependent: :restrict_with_error
  has_many :sales_orders, dependent: :restrict_with_error
  has_many :sales_returns, dependent: :restrict_with_error
  has_many :payments, dependent: :restrict_with_error
  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :purchase_returns, dependent: :restrict_with_error
  has_many :transfer_orders, dependent: :restrict_with_error
  has_many :work_orders, dependent: :restrict_with_error
  has_many :service_asset_categories, dependent: :restrict_with_error
  has_many :service_assets, dependent: :restrict_with_error
  has_many :cash_registers, dependent: :restrict_with_error
  has_many :ledgers, dependent: :restrict_with_error
  has_many :journal_entries, through: :ledgers

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :timezone, presence: true
  validates :currency, presence: true

  def main_location
    store_locations.active.find_by(is_main: true)
  end
end
