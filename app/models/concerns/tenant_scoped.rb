module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :business

    default_scope do
      where(business_id: Current.business_id) if Current.business_id
    end

    before_validation :assign_business, on: :create

    validate :business_matches_current
  end

  private

  def assign_business
    self.business_id ||= Current.business_id
  end

  def business_matches_current
    if Current.business_id && business_id && business_id != Current.business_id
      errors.add(:business_id, "must match the current business")
    end
  end
end
