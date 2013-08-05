class Dash::UsersController < Dash::ApplicationController
  def index
    @users = User.order(created_at: :desc).decorate
  end
end
