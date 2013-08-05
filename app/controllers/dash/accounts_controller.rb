class Dash::AccountsController < Dash::ApplicationController
  def index
    @accounts = Account.order(created_at: :desc)
  end
end
