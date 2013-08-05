class Dash::AccountsController < Dash::ApplicationController
  def index
    @accounts = Account.order(created_at: :desc)
  end

  def show
    @account = Account.find(params[:id])
  end
end
