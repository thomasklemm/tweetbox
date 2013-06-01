class Account::UsersController < AccountController
  before_filter :load_user, only: [:show, :edit, :update, :upgrade_to_admin]

  def index
    @users = account_users
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to edit_account_user_path(@user), notice: 'User has been updated.'
    else
      render :edit
    end
  end

  def upgrade_to_admin
    @account.make_admin!(@user)
    redirect_to account_users_path, notice: "#{ @user.try(:name) } has become an admin of your account."
  end

  private

  def account_users
    user_account.users.decorate
  end

  def account_user
    account_users.find(params[:user_id] || params[:id])
  end

  def load_user
    @user = account_user
  end

  def user_params
    params.require(:user).permit({ project_ids: [] })
  end
end
