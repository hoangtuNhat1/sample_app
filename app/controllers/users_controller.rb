class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create show)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  before_action :find_user, except: %i(index new create)

  def index
    @pagy, @users = pagy User.activated, items: Settings.item_per_page
  end

  def show
    redirect_to root_url and return unless @user.activated?

    @page, @microposts = pagy @user.microposts, items: Settings.item_per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "mail.info"
      redirect_to root_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "update_user.success"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t "destroy.success"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = t "views.users.following"
    @pagy, @users = pagy @user.following, items: Settings.default.page_10
    render "show_follow"
  end

  def followers
    @title = t "views.users.followers"
    @pagy, @users = pagy @user.followers, items: Settings.default.page_10
    render "show_follow"
  end

  private

  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end

  def user_params
    params.require(:user).permit(User::USER_PARAMS)
  end

  def correct_user
    find_user
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "flash.warning"
    redirect_to root_path
  end
end
