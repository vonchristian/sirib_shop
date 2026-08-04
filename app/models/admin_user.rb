class AdminUser < ApplicationRecord
  has_secure_password

  enum :status, { active: 0, inactive: 1 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
