class Category < ApplicationRecord
  include TenantScoped

  enum :status, { active: 0, inactive: 1 }

  belongs_to :parent, class_name: "Category", optional: true

  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :restrict_with_error
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, uniqueness: { scope: :business_id }, allow_blank: true

  before_validation :normalize_code

  validate :parent_belongs_to_same_business

  private

  def normalize_code
    self.code = nil if code.blank?
  end

  def parent_belongs_to_same_business
    if parent && parent.business_id != business_id
      errors.add(:parent, "must belong to the same business")
    end
  end
end
