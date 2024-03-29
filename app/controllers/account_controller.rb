class AccountController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_account
  after_filter :verify_authorized

  layout 'account'

  private

  def load_and_authorize_account
    @account ||= user_account
    authorize @account, :manage?
  end
end
