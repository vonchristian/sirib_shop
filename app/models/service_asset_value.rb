class ServiceAssetValue < ApplicationRecord
  belongs_to :service_asset
  belongs_to :service_asset_field

  validates :service_asset_field_id, uniqueness: { scope: :service_asset_id }

  validate :field_belongs_to_same_category
  validate :value_matches_field_type

  def value
    case service_asset_field&.data_type
    when "text" then text_value
    when "integer" then integer_value
    when "decimal" then decimal_value
    when "date" then date_value
    when "boolean" then boolean_value
    end
  end

  def value=(raw)
    case service_asset_field&.data_type
    when "text"
      self.text_value = raw
    when "integer"
      self.integer_value = raw
    when "decimal"
      self.decimal_value = raw
    when "date"
      self.date_value = raw
    when "boolean"
      self.boolean_value = raw
    end
  end

  private

  def field_belongs_to_same_category
    return unless service_asset_id && service_asset_field_id

    asset = ServiceAsset.find_by(id: service_asset_id)
    field = ServiceAssetField.find_by(id: service_asset_field_id)
    if asset && field && field.service_asset_category_id != asset.service_asset_category_id
      errors.add(:service_asset_field, "must belong to the same category as the service asset")
    end
  end

  def value_matches_field_type
    field = service_asset_field
    return unless field

    case field.data_type
    when "text"
      errors.add(:text_value, "can't be blank") if required? && text_value.blank?
    when "integer"
      errors.add(:integer_value, "must be an integer") if present_with_wrong_type?(integer_value)
    when "decimal"
      errors.add(:decimal_value, "must be a number") if present_with_wrong_type?(decimal_value)
    when "date"
      errors.add(:date_value, "can't be blank") if required? && date_value.blank?
    when "boolean"
      errors.add(:boolean_value, "must be true or false") if !boolean_value.nil? && ![true, false].include?(boolean_value)
    end
  end

  def required?
    service_asset_field.required
  end

  def present_with_wrong_type?(value)
    !value.nil? && !value.is_a?(Numeric)
  end
end
