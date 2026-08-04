class Admin::AdminUsersController < Admin::BaseController
  before_action :set_admin_user, only: %i[edit update]

  def index
    @admin_users = AdminUser.order(:name)
  end

  def new
    @admin_user = AdminUser.new
  end

  def create
    @admin_user = AdminUser.new(admin_user_params)
    if @admin_user.save
      redirect_to admin_admin_users_path, notice: "Admin user created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @admin_user.update(admin_user_params)
      redirect_to admin_admin_users_path, notice: "Admin user updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_admin_user
    @admin_user = AdminUser.find(params[:id])
  end

  def admin_user_params
    params.require(:admin_user).permit(:name, :email, :password, :password_confirmation, :status)
  end
end
