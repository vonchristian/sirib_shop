class LineItem < ApplicationRecord
  include TenantScoped

  enum :movement_type, {
    purchase: 0,
    sale: 1,
    sales_return: 2,
    purchase_return: 3,
    transfer: 4,
    spoilage: 5,
    internal_use: 6,
    adjustment: 7
  }

  belongs_to :stock
  belongs_to :reference, polymorphic: true, optional: true

  validates :quantity, numericality: { not_equal_to: 0 }
  validates :unit_cost_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :occurred_at, presence: true

  validate :reference_belongs_to_same_business

  before_update :immutable!
  before_destroy :immutable!

  def self.adjust(attributes)
    stock = Stock.find(attributes.fetch(:stock_id))
    attributes[:business_id] ||= stock.business_id
    attributes[:occurred_at] ||= Time.current
    create!(attributes)
  end

  private

  def immutable!
    throw :abort
  end

  def reference_belongs_to_same_business
    if reference && reference.respond_to?(:business_id) && reference.business_id != business_id
      errors.add(:reference, "must belong to the same business")
    end
  end
end
