class SessionsController < ApplicationController
  before_action :find_by_email, only: :create

  def create
    if @user&.authenticate(params[:session][:password])
      if @user.activated?
        @forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
        log_in @user
        redirect_to @forwarding_url || @user
      else
        flash[:warning] = t "new_session.not_activate"
        redirect_to root_url
      end
    else
      flash.now[:danger] = t "new_session.invalid"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path, status: :see_other
  end

  private

  def find_by_email
    @user = User.find_by email: params.dig(:session, :email)&.downcase
    return if @user

    flash[:danger] = t "flash.warning"
    redirect_to root_path
  end
end
