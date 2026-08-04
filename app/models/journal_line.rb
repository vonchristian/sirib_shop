class JournalLine < ApplicationRecord
  belongs_to :journal_entry
  belongs_to :account

  validates :debit_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :credit_cents, numericality: { greater_than_or_equal_to: 0 }

  validate :not_both_debit_and_credit
  validate :has_amount

  private

  def not_both_debit_and_credit
    if debit_cents > 0 && credit_cents > 0
      errors.add(:base, "a journal line cannot have both debit and credit")
    end
  end

  def has_amount
    if debit_cents.to_i == 0 && credit_cents.to_i == 0
      errors.add(:base, "a journal line must have a debit or credit amount")
    end
  end
end
