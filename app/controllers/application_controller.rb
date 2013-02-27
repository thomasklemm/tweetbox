class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery

  private

  helper_method :user_accounts, :user_account
  helper_method :user_account_projects, :user_account_project
  helper_method :user_projects, :user_project

  def user_accounts
    @accounts ||= current_user.accounts
  end

  def user_account
    @account ||= user_accounts.find(params[:account_id] || params[:id])
  end

  def user_account_projects
    @account_projects ||= user_account.projects
  end

  def user_account_project
    @account_project ||= user_account_projects.find(params[:project_id] || params[:id])
  end

  def user_projects
    @projects ||= current_user.projects
  end

  def user_project
    @project ||= user_projects.find(params[:project_id] || params[:id])
  end
end
