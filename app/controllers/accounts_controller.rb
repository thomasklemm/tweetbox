class AccountsController < ApplicationController
  before_filter :authenticate_user!
  after_filter :verify_authorized, except: :index

  def index
    @accounts = user_accounts
  end

  def show
    @account = user_accounts.find(params[:id])
    authorize @account

    @projects = user_account_projects
  end

  def new
    @account = user_accounts.new
    authorize @account
  end

  def create
    @account = user_accounts.new(account_params)
    authorize @account
    @account.plan = Plan.trial
    if @account.save
      Membership.create!(user: current_user, account: @account, admin: true)
      redirect_to account_path(@account),
        notice: 'Account was successfully created.'
    else
      render action: :new
      # TODO: Try keeping the url the same on validation errors
    end
  end

  def edit
    @account = user_accounts.find(params[:id])
    authorize @account
  end

  def update
    @account = user_accounts.find(params[:id])
    authorize @account
    if @account.update_attributes(account_params)
      redirect_to account_path(@account),
        notice: 'Account was successfully updated.'
    else
      render action: :edit
    end
  end

  def destroy
    @account = user_accounts.find(params[:id])
    authorize @account
    @account.destroy
    redirect_to accounts_path, notice: 'Account was successfully destroyed.'
    # TODO: Handle case where on attempted account destruction \
    #       there are still projects present, maybe change link in view too.
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
