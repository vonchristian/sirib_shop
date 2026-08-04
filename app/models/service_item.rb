class ServiceItem < ApplicationRecord
  enum :condition, { good: 0, fair: 1, damaged: 2 }
  enum :condition_at_return, { good: 0, fair: 1, damaged: 2 }, prefix: :return_condition

  belongs_to :work_order
  belongs_to :returned_by_user, class_name: "User", optional: true

  validates :tag_number, :name, presence: true
  validates :tag_number, uniqueness: { scope: :work_order_id }
  validates :quantity, numericality: { greater_than: 0 }
  validates :received_at, presence: true

  scope :not_returned, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :ordered, -> { order(:tag_number) }

  def returned?
    returned_at.present?
  end
end
