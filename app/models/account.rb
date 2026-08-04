class Account < ApplicationRecord
  enum :status, { active: 0, inactive: 1 }
  enum :account_type, { asset: 0, liability: 1, equity: 2, revenue: 3, expense: 4 }
  enum :normal_balance, { debit: 0, credit: 1 }

  belongs_to :ledger
  belongs_to :parent, class_name: "Account", optional: true

  has_many :children, class_name: "Account", foreign_key: :parent_id, dependent: :restrict_with_error
  has_many :journal_lines, dependent: :restrict_with_error

  validates :code, :name, presence: true
  validates :code, uniqueness: { scope: :ledger_id }

  validate :parent_belongs_to_same_ledger

  private

  def parent_belongs_to_same_ledger
    if parent && parent.ledger_id != ledger_id
      errors.add(:parent, "must belong to the same ledger")
    end
  end
end
