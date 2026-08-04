module TenantHelpers
  def sign_in_as(user)
    Current.user = user
  end

  def sign_in_admin_as(admin_user)
    Current.admin_user = admin_user
  end

  def clear_current!
    Current.user = nil
    Current.admin_user = nil
  end
end

RSpec.configure do |config|
  config.include TenantHelpers
  config.before(:each) { clear_current! }
end
