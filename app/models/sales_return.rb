class SalesReturn < ApplicationRecord
  include TenantScoped

  enum :status, { open: 0, completed: 1, cancelled: 2 }

  belongs_to :sales_order
  belongs_to :customer, optional: true
  belongs_to :store_location

  has_many :sales_return_lines, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :business_id }

  def customer
    super || sales_order&.customer
  end
end
