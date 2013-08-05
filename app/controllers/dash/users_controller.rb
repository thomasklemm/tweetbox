class Dash::UsersController < Dash::ApplicationController
  def index
    @users = User.order(created_at: :desc).decorate
  end

  def show
    @user = User.find(params[:id])
  end
end
