class UsersController < ApplicationController
  USER_PARAMS = [:name, :email, :password, :password_confirmation].freeze

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "new_user.warning"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = t "new_user.success"
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(*USER_PARAMS)
  end
end
