class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "reset_password.email_sent"
      redirect_to root_path
    else
      flash.now[:danger] = t "reset_password.email_not_found"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if user_params[:password].empty? # Case 3
      @user.errors.add :password, t("reset_password.update.empty")
      render :edit, status: :unprocessable_entity
    elsif @user.update user_params # Case 4
      log_in @user
      @user.update_column :reset_digest, nil
      reset_session
      flash[:success] = t "reset_password.update.success"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity # Case 2
    end
  end

  private

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t "flash.warning"
    redirect_to root_path
  end

  def valid_user
    return if @user&.activated? && @user&.authenticated?(:reset, params[:id])

    flash[:danger] = t "new_session.not_activate"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "reset_password.update.expire"
    redirect_to new_password_reset_url
  end
end
