class Customer < ApplicationRecord
  include TenantScoped

  enum :customer_type, { individual: 0, business: 1, government: 2 }
  enum :status, { active: 0, inactive: 1 }

  belongs_to :parent, class_name: "Customer", optional: true

  has_many :children, class_name: "Customer", foreign_key: :parent_id, dependent: :nullify
  has_many :sales_orders, dependent: :restrict_with_error
  has_many :work_orders, dependent: :restrict_with_error
  has_many :service_assets, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, uniqueness: { scope: :business_id }, allow_blank: true

  before_validation :normalize_code

  scope :active, -> { where(status: :active) }

  private

  def normalize_code
    self.code = nil if code.blank?
  end
end
