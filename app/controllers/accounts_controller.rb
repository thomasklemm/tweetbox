class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_user_account
  after_filter :verify_authorized

  def show
  end

  def edit
  end

  def update
    if @account.update_attributes(account_params)
      redirect_to account_path, notice: 'Account has been updated.'
    else
      render :edit
    end
  end

  private

  def load_and_authorize_user_account
    @account = user_account
    authorize @account, :access?
  end

  def account_params
    params.require(:account).permit(:name)
  end
end
