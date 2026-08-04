class WorkOrderTask < ApplicationRecord
  enum :status, { pending: 0, in_progress: 1, completed: 2, cancelled: 3 }

  belongs_to :work_order
  belongs_to :assigned_user, class_name: "User", optional: true

  validates :description, presence: true

  scope :ordered, -> { order(:id) }
end
