class Product < ApplicationRecord
  include TenantScoped

  enum :status, { active: 0, inactive: 1 }

  belongs_to :category, optional: true

  has_many :variants, class_name: "ProductVariant", dependent: :restrict_with_error

  validates :name, presence: true
end
