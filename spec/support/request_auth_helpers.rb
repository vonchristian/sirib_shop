module RequestAuthHelpers
  def sign_in(user = nil)
    user ||= create(:user)
    post login_path, params: { email: user.email, password: "password123" }
    user
  end

  def sign_in_admin(admin = nil)
    admin ||= create(:admin_user)
    post login_path, params: { email: admin.email, password: "password123" }
    admin
  end
end

RSpec.configure do |config|
  config.include RequestAuthHelpers, type: :request
end
