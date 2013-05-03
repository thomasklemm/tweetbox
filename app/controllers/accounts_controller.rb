class AccountsController < ApplicationController
  before_filter :authenticate_user!
  after_filter :verify_authorized, except: :index

  def index
    @accounts = user_accounts
  end

  def show
    @account = user_account
    authorize @account

    @projects = user_account.projects
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
      @membership = Membership.create!(user: current_user, account: @account, admin: true)
      redirect_to account_path(@account),
        notice: 'Account has been created.'
    else
      render action: :new
      # TODO: Try keeping the url the same on validation errors
    end
  end

  def edit
    @account = user_account
    authorize @account
  end

  def update
    @account = user_account
    authorize @account
    if @account.update_attributes(account_params)
      redirect_to account_path(@account),
        notice: 'Account has been updated.'
    else
      render action: :edit
    end
  end

  def destroy
    @account = user_account
    authorize @account

    begin
      @account.destroy
    rescue ActiveRecord::DeleteRestrictionError
      flash[:alert] = 'Cannot destroy account because there is at least one project associated with it. Please destroy the project(s) first.'
    end

    if @account.destroyed?
      redirect_to accounts_path, notice: 'Account has been destroyed.'
    else
      redirect_to account_path(@account)
    end
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
