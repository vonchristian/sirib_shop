class JournalEntry < ApplicationRecord
  enum :status, { draft: 0, posted: 1, reversed: 2 }

  belongs_to :ledger
  belongs_to :reference, polymorphic: true, optional: true

  has_many :journal_lines, dependent: :destroy

  validates :entry_number, presence: true, uniqueness: { scope: :ledger_id }
  validates :occurred_at, presence: true

  validate :balanced_entries, if: -> { journal_lines.any? }

  before_update :immutable_if_posted
  before_destroy :immutable_if_posted

  def total_debits_cents
    journal_lines.sum(:debit_cents)
  end

  def total_credits_cents
    journal_lines.sum(:credit_cents)
  end

  private

  def balanced_entries
    if total_debits_cents != total_credits_cents
      errors.add(:base, "journal entry must be balanced (debits must equal credits)")
    end
  end

  def immutable_if_posted
    if posted? || reversed?
      errors.add(:base, "posted or reversed journal entries are immutable")
      throw :abort
    end
  end
end
