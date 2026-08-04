class User < ApplicationRecord
  include TenantScoped

  has_secure_password

  enum :status, { active: 0, inactive: 1 }

  has_many :created_sales_orders, class_name: "SalesOrder", foreign_key: :created_by_user_id, dependent: :nullify
  has_many :created_purchase_orders, class_name: "PurchaseOrder", foreign_key: :created_by_user_id, dependent: :nullify
  has_many :created_transfer_orders, class_name: "TransferOrder", foreign_key: :created_by_user_id, dependent: :nullify
  has_many :created_carts, class_name: "Cart", foreign_key: :created_by_user_id, dependent: :nullify
  has_many :assigned_work_orders, class_name: "WorkOrder", foreign_key: :assigned_user_id, dependent: :nullify
  has_many :cash_sessions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :business_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
