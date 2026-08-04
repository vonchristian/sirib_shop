# Cash register session lifecycle.
#
# Expected closing amount = opening float + cash sales - refunds + cash_in - cash_out.
class CashSessionService
  Result = Struct.new(:ok, :cash_session, :errors, keyword_init: true)

  def self.open!(cash_register:, user:, opening_amount_cents: 0)
    CashSession.transaction do
      session = CashSession.new(
        cash_register: cash_register,
        user: user,
        status: :open,
        opened_at: Time.current,
        opening_amount_cents: opening_amount_cents
      )
      session.save!

      session.cash_movements.create!(
        movement_type: :opening,
        amount_cents: opening_amount_cents,
        occurred_at: session.opened_at
      )

      Result.new(ok: true, cash_session: session, errors: [])
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(ok: false, cash_session: nil, errors: e.record.errors.full_messages)
  end

  def self.add_cash!(session, movement_type:, amount_cents:, reference: nil)
    return Result.new(ok: false, cash_session: session, errors: ["session is not open"]) unless session.open?

    session.cash_movements.create!(movement_type: movement_type, amount_cents: amount_cents, reference: reference, occurred_at: Time.current)
    Result.new(ok: true, cash_session: session, errors: [])
  end

  def self.close!(session, actual_closing_amount_cents:)
    return Result.new(ok: false, cash_session: session, errors: ["session is not open"]) unless session.open?

    CashSession.transaction do
      expected = expected_closing_amount_cents(session)
      actual = actual_closing_amount_cents

      rows = CashSession.where(id: session.id, status: :open)
                        .update_all(
                          status: :closed,
                          closed_at: Time.current,
                          expected_closing_amount_cents: expected,
                          actual_closing_amount_cents: actual,
                          difference_cents: actual - expected
                        )
      return Result.new(ok: false, cash_session: session, errors: ["session is not open"]) if rows.zero?

      Result.new(ok: true, cash_session: CashSession.find(session.id), errors: [])
    end
  end

  def self.expected_closing_amount_cents(session)
    session.opening_amount_cents +
      session.cash_movements.where(movement_type: :sale).sum(:amount_cents) -
      session.cash_movements.where(movement_type: :refund).sum(:amount_cents) +
      session.cash_movements.where(movement_type: :cash_in).sum(:amount_cents) -
      session.cash_movements.where(movement_type: :cash_out).sum(:amount_cents)
  end
end
