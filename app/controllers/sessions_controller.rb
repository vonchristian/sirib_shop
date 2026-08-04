class SessionsController < ApplicationController
  skip_before_action :set_current_attributes

  layout "auth"

  def new
    redirect_to root_path if session[:user_id] || session[:admin_user_id]
  end

  def create
    email = params[:email].to_s.strip.downcase
    password = params[:password].to_s

    if (admin_user = AdminUser.find_by(email: email))&.authenticate(password)
      if admin_user.active?
        session[:admin_user_id] = admin_user.id
        redirect_to root_path, notice: "Welcome, #{admin_user.name}."
      else
        flash.now[:alert] = "This admin account is inactive."
        render :new, status: :unprocessable_entity
      end
    elsif (user = User.find_by(email: email))&.authenticate(password)
      if user.active? && user.business&.active?
        session[:user_id] = user.id
        redirect_to root_path, notice: "Welcome, #{user.name}."
      else
        flash.now[:alert] = "This account or business is inactive."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    session.delete(:admin_user_id)
    redirect_to login_path, notice: "Signed out."
  end
end
