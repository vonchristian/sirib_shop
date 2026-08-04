# Records a payment against a sales order.
#
# Cash payments are associated with the active cash session at the order's
# store location and create a matching cash movement. A journal entry moves
# the money from Accounts Receivable to Cash.
class PaymentService
  Result = Struct.new(:created, :payment, :errors, keyword_init: true)

  def self.record!(order:, payment_method:, amount_cents:, reference: nil, paid_at: Time.current)
    ledger = AccountingMapper.ledger_for(order.business)

    Payment.transaction do
      payment = Payment.new(
        business_id: order.business_id,
        sales_order: order,
        payment_method: payment_method,
        amount_cents: amount_cents,
        reference: reference,
        status: :completed,
        paid_at: paid_at
      )

      if payment_method.to_s == "cash"
        session = active_cash_session_for(order)
        payment.cash_session = session
      end

      payment.save!

      if payment.cash_session
        payment.cash_session.cash_movements.create!(
          movement_type: :sale,
          amount_cents: amount_cents,
          reference: payment,
          occurred_at: paid_at
        )
      end

      JournalPostingService.post!(
        ledger: ledger,
        reference: payment,
        description: "Payment for #{order.number} (#{payment_method})",
        occurred_at: paid_at,
        lines: [
          { account: AccountingMapper.account(ledger, :cash), debit_cents: amount_cents,
            description: "Payment received" },
          { account: AccountingMapper.account(ledger, :accounts_receivable), credit_cents: amount_cents,
            description: "Payment for #{order.number}" }
        ]
      )

      order.update!(status: :completed) if order.confirmed? && order.outstanding_balance_cents <= 0

      Result.new(created: true, payment: payment, errors: [])
    end
  rescue JournalPostingService::UnbalancedError, KeyError => e
    Result.new(created: false, payment: nil, errors: [e.message])
  end

  def self.active_cash_session_for(order)
    CashSession.open_sessions
               .joins(cash_register: :store_location)
               .where(cash_registers: { store_location_id: order.store_location_id })
               .order(created_at: :desc)
               .first
  end
end
