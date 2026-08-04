class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_current_attributes

  helper_method :current_user, :current_admin_user, :current_business, :logged_in?

  private

  def set_current_attributes
    Current.admin_user = AdminUser.find_by(id: session[:admin_user_id]) if session[:admin_user_id]
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_user
    Current.user
  end

  def current_admin_user
    Current.admin_user
  end

  def current_business
    Current.business
  end

  def logged_in?
    current_user.present? || current_admin_user.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "Please sign in to continue."
  end

  def require_business_user
    return if current_user

    redirect_to login_path, alert: "Please sign in with a business account."
  end

  def require_admin
    return if current_admin_user

    redirect_to login_path, alert: "Admin access required."
  end

  def current_scope
    if current_user
      { business_id: current_business&.id }
    else
      {}
    end
  end
end
