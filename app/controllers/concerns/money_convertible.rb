# Converts peso/decimal form inputs into integer cents.
module MoneyConvertible
  extend ActiveSupport::Concern

  private

  def money_value(value)
    return 0 if value.blank?

    (value.to_s.gsub(/[^\d.-]/, "").to_f * 100).round
  end
end
