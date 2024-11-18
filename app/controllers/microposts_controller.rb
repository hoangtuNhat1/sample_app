class MicropostsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t "microposts.created"
      redirect_to root_url
    else
      @pagy, @feed_items = pagy current_user.feed.newest,
                                items: Settings.item_per_page
      render "static_pages/home", status: :unprocessable_entity
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "microposts.success_delete_message"
    else
      flash[:danger] = t "microposts.fail_delete_message"
    end
    redirect_to request.referer || root_url
  end

  private
  def micropost_params
    params.require(:micropost).permit Micropost::PERMITTED_PARAMS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t "microposts.invalid"
    redirect_to root_url
  end
end
