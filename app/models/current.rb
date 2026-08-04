class Current < ActiveSupport::CurrentAttributes
  attribute :admin_user, :user

  def business
    user&.business
  end

  def business_id
    business&.id
  end
end
