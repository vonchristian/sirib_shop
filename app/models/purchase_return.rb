class PurchaseReturn < ApplicationRecord
  include TenantScoped

  enum :status, { open: 0, completed: 1, cancelled: 2 }

  belongs_to :purchase_order
  belongs_to :supplier
  belongs_to :store_location

  has_many :purchase_return_lines, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :business_id }
end
